#include "controller.h"
#include <QCryptographicHash>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPasswordDigestor>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QSaveFile>
#include <QStandardPaths>
#include <QTextStream>

namespace {
const QStringList names = {QStringLiteral("回收"), QStringLiteral("不可回收"), QStringLiteral("厨余垃圾"), QStringLiteral("湿垃圾")};
const QStringList colors = {"#55B5F8", "#A5ADBC", "#E9AF65", "#58D5AE"};
const QStringList examples = {QStringLiteral("纸张 · 塑料 · 金属"), QStringLiteral("纸巾 · 陶瓷 · 尘土"), QStringLiteral("剩饭 · 菜叶 · 果皮"), QStringLiteral("按项目自定义规则")};
QByteArray derive(const QString &password, const QByteArray &salt) {
    return QPasswordDigestor::deriveKeyPbkdf2(QCryptographicHash::Sha256, password.toUtf8(), salt, 120000, 32);
}
QString csvCell(QString s) {
    // Guard spreadsheet formula interpretation, including whitespace prefixes.
    const QString trimmed = s.trimmed();
    if (!trimmed.isEmpty() && QString("=+-@").contains(trimmed.front())) s.prepend('\'');
    s.replace('"', "\"\"");
    return '"' + s + '"';
}
}

Controller::Controller(QString directory, QObject *parent) : QObject(parent),
    m_directory(directory.isEmpty() ? QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) : directory) {
    QDir().mkpath(m_directory);
    QFile file(m_directory + "/events.json");
    if (file.exists()) {
        if (file.open(QIODevice::ReadOnly)) {
            const auto doc = QJsonDocument::fromJson(file.readAll());
            if (doc.isArray()) {
                m_logs = doc.array().toVariantList();
                while (m_logs.size() > 2000) m_logs.removeLast();
            } else m_error = QStringLiteral("历史日志文件损坏，新的日志将重新保存。");
        } else m_error = QStringLiteral("无法读取历史日志，请检查数据目录权限。");
    }
    m_timer.setInterval(3000);
    connect(&m_timer, &QTimer::timeout, this, &Controller::sample);
}
bool Controller::firstRun() const { return !QFile::exists(m_directory + "/account.json"); }
void Controller::setError(const QString &message) { m_error = message; emit errorChanged(); }
bool Controller::createAccount(const QString &name, const QString &password) {
    if (!firstRun()) { setError(QStringLiteral("本机已有账号，请登录。")); return false; }
    if (!QRegularExpression("^[A-Za-z0-9_-]{3,24}$").match(name.trimmed()).hasMatch()) {
        setError(QStringLiteral("用户名需为 3–24 位字母、数字、下划线或短横线。")); return false;
    }
    if (password.size() < 8 || password.size() > 128) {
        setError(QStringLiteral("密码长度需为 8–128 位。")); return false;
    }
    QByteArray salt(16, Qt::Uninitialized);
    for (char &ch : salt) ch = static_cast<char>(QRandomGenerator::system()->generate() & 0xff);
    QJsonObject obj{{"name", name.trimmed()}, {"salt", QString::fromLatin1(salt.toHex())},
                    {"hash", QString::fromLatin1(derive(password, salt).toHex())}, {"iterations", 120000}};
    QSaveFile file(m_directory + "/account.json");
    const auto data = QJsonDocument(obj).toJson();
    if (!file.open(QIODevice::WriteOnly) || file.write(data) != data.size() || !file.commit()) {
        setError(QStringLiteral("账号保存失败，请检查数据目录权限。")); return false;
    }
    beginSession(name.trimmed());
    addLog("INFO", QStringLiteral("账号"), QStringLiteral("本地账号创建成功"));
    return true;
}
bool Controller::login(const QString &name, const QString &password) {
    QFile file(m_directory + "/account.json");
    if (!file.open(QIODevice::ReadOnly)) { setError(QStringLiteral("无法读取账号文件。")); return false; }
    const auto obj = QJsonDocument::fromJson(file.readAll()).object();
    const auto salt = QByteArray::fromHex(obj["salt"].toString().toLatin1());
    const auto expected = QByteArray::fromHex(obj["hash"].toString().toLatin1());
    if (salt.size() != 16 || expected.size() != 32 || obj["iterations"].toInt() != 120000) {
        setError(QStringLiteral("账号文件损坏，请恢复备份。演示模式仍可使用。")); return false;
    }
    if (password.size() > 128) { setError(QStringLiteral("用户名或密码不正确。")); return false; }
    const auto actual = derive(password, salt);
    unsigned char diff = 0;
    for (int i = 0; i < expected.size(); ++i) diff |= static_cast<unsigned char>(actual[i] ^ expected[i]);
    if (name.trimmed() != obj["name"].toString() || diff) {
        setError(QStringLiteral("用户名或密码不正确。"));
        addLog("WARN", QStringLiteral("账号"), QStringLiteral("登录验证失败")); return false;
    }
    beginSession(name.trimmed()); return true;
}
void Controller::beginSession(const QString &name) {
    m_authenticated = true; m_user = name; setError({});
    addLog("INFO", QStringLiteral("账号"), QStringLiteral("%1 进入演示工作台").arg(name));
    emit authChanged();
}
void Controller::enterDemo() { beginSession(QStringLiteral("演示访客")); }
void Controller::logout() {
    m_timer.stop();
    addLog("INFO", QStringLiteral("账号"), QStringLiteral("%1 已退出，自动演示已停止").arg(m_user));
    m_authenticated = false; m_user.clear(); setError({});
    emit authChanged(); emit stateChanged();
}
QVariantList Controller::categories() const {
    QVariantList result;
    for (int i = 0; i < 4; ++i)
        result.append(QVariantMap{{"name", names[i]}, {"color", colors[i]}, {"examples", examples[i]},
            {"count", m_counts[i]}, {"fill", m_fill[i]}, {"code", QString("0%1").arg(i + 1)}});
    return result;
}
void Controller::setInterval(int seconds) {
    if (!m_authenticated) return;
    const int bounded = qBound(1, seconds, 10);
    m_timer.setInterval(bounded * 1000);
    addLog("INFO", QStringLiteral("设置"), QStringLiteral("演示间隔调整为 %1 秒").arg(bounded));
    emit stateChanged();
}
void Controller::toggleRunning() {
    if (!m_authenticated) return;
    if (running()) { m_timer.stop(); addLog("INFO", QStringLiteral("运行"), QStringLiteral("自动演示已暂停")); }
    else { m_timer.start(); addLog("INFO", QStringLiteral("运行"), QStringLiteral("自动演示已启动；未连接真实设备")); }
    emit stateChanged();
}
void Controller::sample() {
    if (!m_authenticated) return;
    int i = m_total % 4;
    if (m_fill[i] >= 100) {
        m_timer.stop();
        addLog("WARN", QStringLiteral("桶体"), names[i] + QStringLiteral("桶已满，请先模拟清空"));
        emit notice(QStringLiteral("桶体已满，演示已停止。请模拟清空后继续。"));
        emit stateChanged(); return;
    }
    const QStringList items = {QStringLiteral("塑料饮料瓶"), QStringLiteral("废弃纸巾"), QStringLiteral("蔬菜残叶"), QStringLiteral("湿垃圾样本")};
    ++m_counts[i]; ++m_total;
    m_fill[i] = qMin(100, m_fill[i] + 4);
    m_latest = {{"name", items[i]}, {"category", names[i]}, {"index", i}, {"color", colors[i]},
        {"confidence", 96.2 + (m_total % 7) * 0.4}, {"time", QDateTime::currentDateTime().toString("HH:mm:ss")}};
    addLog("INFO", QStringLiteral("分类"), QStringLiteral("[演示] %1 → %2，投放完成").arg(items[i], names[i]));
    if (m_fill[i] == 80) addLog("WARN", QStringLiteral("桶体"), names[i] + QStringLiteral("桶余量不足 20%，请关注"));
    emit stateChanged();
}
void Controller::emptyBin(int i) {
    if (!m_authenticated || i < 0 || i > 3) return;
    m_fill[i] = 0;
    addLog("INFO", QStringLiteral("桶体"), QStringLiteral("[演示] 已模拟清空%1桶，累计数量保留").arg(names[i]));
    emit stateChanged(); emit notice(QStringLiteral("已模拟清空桶体"));
}
void Controller::addLog(const QString &level, const QString &module, const QString &message) {
    m_logs.prepend(QVariantMap{{"time", QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss")},
        {"level", level}, {"module", module}, {"message", message}});
    while (m_logs.size() > 2000) m_logs.removeLast();
    if (!persistLogs()) emit notice(QStringLiteral("日志写入失败；本次事件仅保留在内存中。"));
    emit logsChanged();
}
bool Controller::persistLogs() {
    QSaveFile file(m_directory + "/events.json");
    auto data = QJsonDocument(QJsonArray::fromVariantList(m_logs)).toJson(QJsonDocument::Compact);
    return file.open(QIODevice::WriteOnly) && file.write(data) == data.size() && file.commit();
}
QVariantList Controller::filteredLogs(const QString &level, const QString &query) const {
    QVariantList result;
    for (const auto &v : m_logs) {
        const auto r = v.toMap();
        if (level != "ALL" && r["level"].toString() != level) continue;
        const auto all = r["message"].toString() + r["module"].toString() + r["time"].toString();
        if (!all.contains(query.trimmed(), Qt::CaseInsensitive)) continue;
        result.append(v);
    }
    return result;
}
bool Controller::exportLogs(const QUrl &url, const QString &level, const QString &query) {
    if (!m_authenticated || !url.isLocalFile()) return false;
    // Never allow export to overwrite the application's account or log storage.
    const QString path = QDir::cleanPath(url.toLocalFile());
    if (QFileInfo(path).absolutePath().compare(QFileInfo(m_directory).absoluteFilePath(), Qt::CaseInsensitive) == 0
        && (QFileInfo(path).fileName().compare("account.json", Qt::CaseInsensitive) == 0
            || QFileInfo(path).fileName().compare("events.json", Qt::CaseInsensitive) == 0)) {
        emit notice(QStringLiteral("请选择其他文件名，不能覆盖应用数据。")); return false;
    }
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) { emit notice(QStringLiteral("导出失败，请选择可写入的位置。")); return false; }
    QByteArray data = QByteArray::fromHex("EFBBBF") + QStringLiteral("时间,级别,模块,内容\r\n").toUtf8();
    for (const auto &v : filteredLogs(level, query)) {
        const auto r = v.toMap();
        QStringList cells;
        for (const auto &key : {"time", "level", "module", "message"}) cells << csvCell(r[key].toString());
        data += (cells.join(',') + "\r\n").toUtf8();
    }
    if (file.write(data) != data.size() || !file.commit()) { emit notice(QStringLiteral("导出失败，文件未保存。")); return false; }
    emit notice(QStringLiteral("日志已导出：") + path); return true;
}
void Controller::seedPreview() {
    enterDemo();
    for (int i = 0; i < 29; ++i) sample();
}
