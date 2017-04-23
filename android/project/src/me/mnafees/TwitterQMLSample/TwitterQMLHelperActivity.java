package me.mnafees.TwitterQMLSample;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.twitter.sdk.android.Twitter;
import com.twitter.sdk.android.core.Callback;
import com.twitter.sdk.android.core.Result;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.core.models.User;
import com.twitter.sdk.android.tweetcomposer.TweetComposer;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import io.fabric.sdk.android.Fabric;
import retrofit2.Call;
import retrofit2.Response;

import org.qtproject.qt5.android.bindings.QtActivity;

public class TwitterQMLHelperActivity extends QtActivity {

    private static String TAG = "TwitterQMLHelper";
    private static TwitterQMLHelperActivity mInstance;
    private static final String TWITTER_KEY = "XbYthtCJPTFWdgsGcdunbO0bt";
    private static final String TWITTER_SECRET = "3ocudqJ4NqZYbwxtV6A9NwM6YKHU7UwSBx8umKSFrfKjMNyDHN";

    private TwitterAuthClient mAuthClient;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mInstance = this;
        TwitterAuthConfig authConfig = new TwitterAuthConfig(TWITTER_KEY, TWITTER_SECRET);
        Fabric.with(this, new Twitter(authConfig));
    }

    private TwitterAuthClient getAuthClient() {
        if (mAuthClient == null) {
            mAuthClient = new TwitterAuthClient();
        }
        return mAuthClient;
    }

    public static void login() {
        mInstance.getAuthClient().authorize(mInstance, new Callback<TwitterSession>() {
            @Override
            public void success(Result<TwitterSession> result) {
                TwitterQMLCallbacks.onLoginSuccess();
            }

            @Override
            public void failure(TwitterException exception) {
                TwitterQMLCallbacks.onLoginFailed(exception.getMessage());
            }
        });
    }

    public static void logout() {
        Twitter.logOut();
    }

    public static boolean isLoggedIn() {
        return Twitter.getSessionManager().getActiveSession() != null;
    }

    public static void fetchUserProfile() {
        final TwitterSession session = Twitter.getSessionManager().getActiveSession();
        Twitter.getApiClient(session).getAccountService()
                .verifyCredentials(true, false)
                .enqueue(new retrofit2.Callback<User>() {
            @Override
            public void onResponse(Call<User> call, Response<User> response) {
                if (response.isSuccessful()) {
                    User user = response.body();
                    TwitterQMLCallbacks.onUserProfileFetched(user.idStr, user.name,
                            user.url, user.profileImageUrlHttps);
                } else {
                    Log.e(TAG, response.errorBody().toString());
                }
            }

            @Override
            public void onFailure(Call<User> call, Throwable t) {
                Log.e(TAG, t.getMessage());
            }
        });
    }

    public static void tweet(String text, String url) {
        try {
            TweetComposer.Builder builder = new TweetComposer.Builder(mInstance)
                    .text(text)
                    .url(new URL(url));
            builder.show();
        } catch (MalformedURLException e) {
            Log.e(TAG, e.getMessage());
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        getAuthClient().onActivityResult(requestCode, resultCode, data);
    }

}

class TwitterQMLCallbacks {

    public static native void onLoginSuccess();

    public static native void onLoginFailed(String error);

    public static native void onUserProfileFetched(String id, String name,
                                                   String url, String profileImageUrl);

}
