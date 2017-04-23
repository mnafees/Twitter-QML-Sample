#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "common/TwitterQML.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<TwitterQML>("me.mnafees", 1, 0, "Twitter");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
