package com.example.cnvitals;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import sdk.carenow.cnvitals.Calibration;

import static android.app.Activity.RESULT_OK;

/**
 * CnvitalsPlugin
 */
public class CnvitalsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;
    private Result mResult;
    private Activity activity;
    private PluginRegistry.Registrar registrar;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "cnvitals");
        context = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getVitals")) {
            mResult = result;
            startVitalsMeasurement(call);
        } else {
            result.notImplemented();
        }
    }

    private void startVitalsMeasurement(MethodCall call) {
        Intent intent = new Intent(context.getApplicationContext(), Calibration.class);
        intent.putExtra("api_key", (String) call.argument("api_key"));
        intent.putExtra("scan_token", (String) call.argument("scan_token"));
        intent.putExtra("employee_id", (String) call.argument("employee_id"));
        intent.putExtra("language", (String) call.argument("language"));
        intent.putExtra("color_code", (String) call.argument("color_code"));
        intent.putExtra("measured_height", (String) call.argument("measured_height"));
        intent.putExtra("measured_weight", (String) call.argument("measured_weight"));
        intent.putExtra("posture", (String) call.argument("posture"));
        activity.startActivityForResult(intent, 90);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
        SharedPreferences pref = context.getSharedPreferences("CNV", 0);
        String otherResponse = pref.getString("message", "");
        JSONObject item = new JSONObject();
        if (resultCode == RESULT_OK) {
            StringBuilder str = new StringBuilder();
            int heartrate = pref.getInt("heart_rate", 0);
            int O2R = pref.getInt("spo2", 0);
            int Breath = pref.getInt("resp_rate", 0);
            int BPM = pref.getInt("heart_rate_cnv", 0);
            String ppgData = pref.getString("ecgdata", "");
            String ecgData = pref.getString("ppgdata", "");
            String heartDataArray = pref.getString("heartDataArray", "");
            String apiResponse = pref.getString("api_result", "");
            try {
                item.put("breath", Breath);
                item.put("O2R", O2R);
                item.put("bpm2", BPM);
                item.put("bpm", heartrate);
                item.put("ecgdata", ecgData);
                item.put("ppgdata", ppgData);
                item.put("heartdata", heartData);
                item.put("heartDataArray", heartDataArray);
                item.put("apiResponse",apiResponse)
            } catch (JSONException e) {

            }
            mResult.success(item.toString());
        } else {
            try {
                item.put("message", otherResponse);
                item.put("reason", "Cancelled");
                mResult.success(item.toString());
            } catch (JSONException e) {

            }
        }
        return false;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
