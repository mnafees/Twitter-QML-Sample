#include "common/TwitterQML.h"

#include <QGuiApplication>
#include <qpa/qplatformnativeinterface.h>

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <Fabric/Fabric.h>
#include <TwitterKit/TwitterKit.h>

static TwitterQML *m_instance{nullptr};

@interface QIOSApplicationDelegate
@end

@interface QIOSApplicationDelegate (TwitterQMLDelegate)
@end

@implementation QIOSApplicationDelegate (TwitterQMLDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Twitter class]]];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([[Twitter sharedInstance] application:app openURL:url options:options]) {
        return YES;
    }

    return NO;
}

@end

TwitterQML::TwitterQML(QObject *parent) :
    QObject(parent)
{
    TwitterQMLInstance::setInstance(this);
}

TwitterQML::~TwitterQML()
{
}

void TwitterQML::login()
{
    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    UIView *view = static_cast<UIView *>(nativeInterface->nativeResourceForWindow("uiview", qApp->topLevelWindows().at(0)));
    UIViewController *qtController = [[view window] rootViewController];

    [[Twitter sharedInstance] logInWithViewController:qtController completion:^(TWTRSession *session, NSError *error) {
      if (session) {
          emit loginSuccess();
      } else {
          emit loginFailed(QString::fromNSString([error localizedDescription]));
      }
    }];
}

void TwitterQML::logout()
{
    TWTRSessionStore* sessionStore = [[Twitter sharedInstance] sessionStore];
    [sessionStore logOutUserID:[[sessionStore session] userID]];
}

bool TwitterQML::isLoggedIn()
{
    TWTRSessionStore* sessionStore = [[Twitter sharedInstance] sessionStore];
    if ([sessionStore session]) {
        return true;
    }
    return false;
}

void TwitterQML::fetchUserProfile()
{
    TWTRSessionStore* sessionStore = [[Twitter sharedInstance] sessionStore];
    [[TWTRAPIClient clientWithCurrentUser] loadUserWithID:[[sessionStore session] userID]
            completion:^(TWTRUser *user, NSError *error) {
        QString profileUrl = "https://twitter.com/";
        profileUrl += QString::fromNSString([user screenName]);
        emit userProfileFetched(QString::fromNSString([user userID]),
                                QString::fromNSString([user name]),
                                profileUrl,
                                QString::fromNSString([user profileImageURL]));
    }];
}

void TwitterQML::tweet(const QString &text, const QString &url)
{
    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    UIView *view = static_cast<UIView *>(nativeInterface->nativeResourceForWindow("uiview", qApp->topLevelWindows().at(0)));
    UIViewController *qtController = [[view window] rootViewController];

    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:text.toNSString()];
    [composer setURL:[NSURL URLWithString:url.toNSString()]];
    [composer showFromViewController:qtController completion:^(TWTRComposerResult result) {
    }];
}

void TwitterQMLInstance::setInstance(TwitterQML *instance)
{
    m_instance = instance;
}

TwitterQML *TwitterQMLInstance::instance()
{
    return m_instance;
}
