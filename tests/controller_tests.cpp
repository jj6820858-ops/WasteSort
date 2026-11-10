#include <QtTest>
#include <QTemporaryDir>
#include <QFile>
#include "controller.h"

class ControllerTests : public QObject {
    Q_OBJECT
private slots:
    void accountSurvivesRestart() {
        QTemporaryDir dir;
        Controller first(dir.path());
        QVERIFY(first.firstRun());
        QVERIFY(!first.createAccount("operator", "short"));
        QVERIFY(first.createAccount("operator", "test-pass-2026"));
        QVERIFY(first.authenticated());
        first.logout();
        Controller second(dir.path());
        QVERIFY(!second.firstRun());
        QVERIFY(!second.login("operator", "incorrect"));
        QVERIFY(second.login("operator", "test-pass-2026"));
        QFile file(dir.filePath("account.json"));
        QVERIFY(file.open(QIODevice::ReadOnly));
        QVERIFY(!file.readAll().contains("test-pass-2026"));
    }
    void sessionGuardsAndCounters() {
        QTemporaryDir dir;
        Controller c(dir.path());
        c.sample();
        QCOMPARE(c.total(), 0);
        c.toggleRunning();
        QVERIFY(!c.running());
        c.enterDemo();
        for (int i = 0; i < 8; ++i) c.sample();
        QCOMPARE(c.total(), 8);
        int sum = 0;
        for (const auto &v : c.categories()) sum += v.toMap()["count"].toInt();
        QCOMPARE(sum, c.total());
        c.toggleRunning();
        QVERIFY(c.running());
        c.logout();
        QVERIFY(!c.running());
        c.sample();
        QCOMPARE(c.total(), 8);
        QVERIFY(!c.authenticated());
    }
    void logPersistenceFilterAndExport() {
        QTemporaryDir dir;
        Controller c(dir.path());
        c.enterDemo();
        c.sample();
        QVERIFY(c.filteredLogs("INFO", "分类").size() > 0);
        QCOMPARE(c.filteredLogs("ERROR", "unlikely-text").size(), 0);
        const auto path = dir.filePath("logs.csv");
        QVERIFY(c.exportLogs(QUrl::fromLocalFile(path), "INFO", "分类"));
        QFile file(path);
        QVERIFY(file.open(QIODevice::ReadOnly));
        QVERIFY(file.readAll().contains(QString("分类").toUtf8()));
        Controller restored(dir.path());
        QVERIFY(restored.logs().size() > 0);
        QVERIFY(!restored.exportLogs(QUrl::fromLocalFile(dir.filePath("blocked.csv")), "ALL", ""));
    }
    void damagedAccountIsNotFirstRun() {
        QTemporaryDir dir;
        QFile file(dir.filePath("account.json"));
        QVERIFY(file.open(QIODevice::WriteOnly));
        file.write("broken"); file.close();
        Controller c(dir.path());
        QVERIFY(!c.firstRun());
        QVERIFY(!c.login("operator", "test-pass-2026"));
        QVERIFY(!c.createAccount("another", "test-pass-2026"));
    }
    void fullBinStopsUntilEmptied() {
        QTemporaryDir dir;
        Controller c(dir.path());
        c.enterDemo();
        for (int i = 0; i < 100; ++i) c.sample();
        QCOMPARE(c.total(), 100);
        c.toggleRunning();
        c.sample();
        QVERIFY(!c.running());
        QCOMPARE(c.total(), 100);
        QVERIFY(!c.filteredLogs("WARN", QStringLiteral("桶已满")).isEmpty());
        c.emptyBin(0);
        c.sample();
        QCOMPARE(c.total(), 101);
        QCOMPARE(c.categories()[0].toMap()["count"].toInt(), 26);
        QVERIFY(!c.exportLogs(QUrl::fromLocalFile(dir.filePath("events.json")), "ALL", ""));
    }
};
QTEST_GUILESS_MAIN(ControllerTests)
#include "controller_tests.moc"
