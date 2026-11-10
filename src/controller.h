#pragma once
#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QUrl>

class Controller : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool firstRun READ firstRun NOTIFY authChanged)
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authChanged)
    Q_PROPERTY(QString user READ user NOTIFY authChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(bool running READ running NOTIFY stateChanged)
    Q_PROPERTY(int total READ total NOTIFY stateChanged)
    Q_PROPERTY(QVariantList categories READ categories NOTIFY stateChanged)
    Q_PROPERTY(QVariantMap latest READ latest NOTIFY stateChanged)
    Q_PROPERTY(QVariantList logs READ logs NOTIFY logsChanged)
    Q_PROPERTY(QString dataPath READ dataPath CONSTANT)
    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY stateChanged)
public:
    explicit Controller(QString directory = {}, QObject *parent = nullptr);
    bool firstRun() const;
    bool authenticated() const { return m_authenticated; }
    QString user() const { return m_user; }
    QString error() const { return m_error; }
    bool running() const { return m_timer.isActive(); }
    int total() const { return m_total; }
    QVariantList categories() const;
    QVariantMap latest() const { return m_latest; }
    QVariantList logs() const { return m_logs; }
    QString dataPath() const { return m_directory; }
    int interval() const { return m_timer.interval() / 1000; }
    void setInterval(int seconds);
    Q_INVOKABLE bool createAccount(const QString &name, const QString &password);
    Q_INVOKABLE bool login(const QString &name, const QString &password);
    Q_INVOKABLE void enterDemo();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void toggleRunning();
    Q_INVOKABLE void sample();
    Q_INVOKABLE void emptyBin(int index);
    Q_INVOKABLE QVariantList filteredLogs(const QString &level, const QString &query) const;
    Q_INVOKABLE bool exportLogs(const QUrl &url, const QString &level, const QString &query);
    void seedPreview();
signals:
    void authChanged();
    void stateChanged();
    void errorChanged();
    void logsChanged();
    void notice(const QString &message);
private:
    void setError(const QString &message);
    void addLog(const QString &level, const QString &module, const QString &message);
    void beginSession(const QString &name);
    bool persistLogs();
    QString m_directory, m_user, m_error;
    bool m_authenticated = false;
    int m_total = 0;
    int m_counts[4] = {0, 0, 0, 0};
    int m_fill[4] = {0, 0, 0, 0};
    QVariantMap m_latest;
    QVariantList m_logs;
    QTimer m_timer;
};
