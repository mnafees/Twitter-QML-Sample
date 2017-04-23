#ifndef TwitterQML_h
#define TwitterQML_h

#include <QObject>

class TwitterQML : public QObject
{
    Q_OBJECT
public:
    explicit TwitterQML(QObject *parent = 0);
    ~TwitterQML();

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool isLoggedIn();
    Q_INVOKABLE void fetchUserProfile();
    Q_INVOKABLE void tweet(const QString& text, const QString& url);

signals:
    void loginSuccess();
    void loginFailed(QString error);
    void userProfileFetched(QString id, QString name, QString url, QString profileImageUrl);
};

class TwitterQMLInstance
{
public:
    static void setInstance(TwitterQML *instance);
    static TwitterQML* instance();
};

#endif // TwitterQML_h
