package io.github.edufolly.fluttermobilevision.ocr;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Camera;
import android.util.DisplayMetrics;

import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.vision.MultiProcessor;
import com.google.android.gms.vision.text.TextRecognizer;

import java.util.ArrayList;

import io.github.edufolly.fluttermobilevision.ui.CameraSource;
import io.github.edufolly.fluttermobilevision.util.AbstractCaptureActivity;
import io.github.edufolly.fluttermobilevision.util.MobileVisionException;

public final class OcrCaptureActivity extends AbstractCaptureActivity<OcrGraphic> {

    protected ArrayList<MyTextBlock> textList;
    protected PictureDone picCallback;

    @SuppressLint("InlinedApi")
    protected void createCameraSource() throws MobileVisionException {
        this.picture = null;
        this.picCallback = new PictureDone(this);

        Context context = getApplicationContext();

        TextRecognizer textRecognizer = new TextRecognizer.Builder(context)
                .build();

        OcrTrackerFactory ocrTrackerFactory = new OcrTrackerFactory(graphicOverlay, showText);

        textRecognizer.setProcessor(
                new MultiProcessor.Builder<>(ocrTrackerFactory).build());

        if (!textRecognizer.isOperational()) {
            IntentFilter lowStorageFilter = new IntentFilter(Intent.ACTION_DEVICE_STORAGE_LOW);
            boolean hasLowStorage = registerReceiver(null, lowStorageFilter) != null;

            if (hasLowStorage) {
                throw new MobileVisionException("Low Storage.");
            }
        }

        DisplayMetrics metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);

        cameraSource = new CameraSource
                .Builder(getApplicationContext(), textRecognizer)
                .setFacing(camera)
                .setRequestedPreviewSize(metrics.heightPixels, metrics.widthPixels)
                .setFocusMode(autoFocus ? Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE : null)
                .setFlashMode(useFlash ? Camera.Parameters.FLASH_MODE_TORCH : null)
                .setRequestedFps(fps)
                .build();
    }

    protected boolean onTap(float rawX, float rawY) {
        ArrayList<MyTextBlock> list = new ArrayList<>();

        if (multiple) {
            for (OcrGraphic graphic : graphicOverlay.getGraphics()) {
                list.add(new MyTextBlock(graphic.getTextBlock()));
            }
        } else {
            OcrGraphic graphic = graphicOverlay.getBest(rawX, rawY);
            if (graphic != null && graphic.getTextBlock() != null) {
                list.add(new MyTextBlock(graphic.getTextBlock()));
            }
        }

        if (!list.isEmpty()) {
            this.textList = list;
            cameraSource.takePicture(null, this.picCallback);
            return true;
        }

        return false;
    }

    private class PictureDone implements CameraSource.PictureCallback {
        protected OcrCaptureActivity capture;

        PictureDone(OcrCaptureActivity capture) {
            this.capture = capture;
        }

        @Override
        public void onPictureTaken(byte[] data) {
            Intent allData = new Intent();
            allData.putExtra(OBJECT, capture.textList);
            allData.putExtra(IMAGE, data);
            this.capture.setResult(CommonStatusCodes.SUCCESS, allData);
            this.capture.finish();
        }
    }
}