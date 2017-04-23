#include "common/TwitterQML.h"
#include "android/AndroidGlobals.h"

#include <QtAndroid>

static TwitterQML *m_instance{nullptr};

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
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "TwitterQMLHelperActivity").toUtf8().data(),
                                              "login", "()V");
}

void TwitterQML::logout()
{
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "TwitterQMLHelperActivity").toUtf8().data(),
                                              "logout", "()V");
}

bool TwitterQML::isLoggedIn()
{
    return QAndroidJniObject::callStaticMethod<jboolean>(QString(javaPackage + "TwitterQMLHelperActivity").toUtf8().data(),
                                              "isLoggedIn", "()Z");
}

void TwitterQML::fetchUserProfile()
{
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "TwitterQMLHelperActivity").toUtf8().data(),
                                              "fetchUserProfile", "()V");
}

void TwitterQML::tweet(const QString &text, const QString &url)
{
    QAndroidJniObject::callStaticMethod<void>(QString(javaPackage + "TwitterQMLHelperActivity").toUtf8().data(),
                                              "tweet", "(Ljava/lang/String;Ljava/lang/String;)V",
                                              QAndroidJniObject::fromString(text).object<jstring>(),
                                              QAndroidJniObject::fromString(url).object<jstring>());
}

static void onLoginSuccess(JNIEnv */*env*/, jobject /*obj*/);
static void onLoginFailed(JNIEnv */*env*/, jobject /*obj*/, jstring error);
static void onUserProfileFetched(JNIEnv */*env*/, jobject /*obj*/, jstring id, jstring name,
                                 jstring url, jstring profileImageUrl);

static JNINativeMethod methods[] = {
    {
        "onLoginSuccess",
        "()V",
        (void*)onLoginSuccess
    },
    {
        "onLoginFailed",
        "(Ljava/lang/String;)V",
        (void*)onLoginFailed
    },
    {
        "onUserProfileFetched",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
        (void*)onUserProfileFetched
    }
};

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    jclass callbackClass = env->FindClass(QString(javaPackage + "TwitterQMLCallbacks").toUtf8().data());
    if (!callbackClass) {
        return JNI_ERR;
    }

    if (env->RegisterNatives(callbackClass, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        return JNI_ERR;
    }

    return JNI_VERSION_1_6;
}

static void onLoginSuccess(JNIEnv */*env*/, jobject /*obj*/)
{
    emit TwitterQMLInstance::instance()->loginSuccess();
}

static void onLoginFailed(JNIEnv */*env*/, jobject /*obj*/, jstring error)
{
    const QAndroidJniObject qserror(error);
    emit TwitterQMLInstance::instance()->loginFailed(qserror.toString());
}

static void onUserProfileFetched(JNIEnv */*env*/, jobject /*obj*/, jstring id, jstring name,
                                 jstring url, jstring profileImageUrl)
{
    const QAndroidJniObject qsid(id);
    const QAndroidJniObject qsname(name);
    const QAndroidJniObject qsurl(url);
    const QAndroidJniObject qsprofileImageUrl(profileImageUrl);
    emit TwitterQMLInstance::instance()->userProfileFetched(qsid.toString(),
                                                            qsname.toString(),
                                                            qsurl.toString(),
                                                            qsprofileImageUrl.toString());
}

void TwitterQMLInstance::setInstance(TwitterQML *instance)
{
    m_instance = instance;
}

TwitterQML *TwitterQMLInstance::instance()
{
    return m_instance;
}
