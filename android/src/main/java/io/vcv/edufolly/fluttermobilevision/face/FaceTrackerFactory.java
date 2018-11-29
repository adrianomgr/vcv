package io.vcv.edufolly.fluttermobilevision.face;

import android.util.Log;

import com.google.android.gms.vision.MultiProcessor;
import com.google.android.gms.vision.Tracker;
import com.google.android.gms.vision.face.Face;

import io.vcv.edufolly.fluttermobilevision.ui.GraphicOverlay;

public class FaceTrackerFactory implements MultiProcessor.Factory<Face> {
    private GraphicOverlay<FaceGraphic> graphicOverlay;
    private boolean showText;

    public FaceTrackerFactory(GraphicOverlay<FaceGraphic> graphicOverlay, boolean showText) {
        this.graphicOverlay = graphicOverlay;
        this.showText = showText;
    }

    @Override
    public Tracker<Face> create(Face face) {
        FaceGraphic graphic = new FaceGraphic(graphicOverlay, showText);
        try {
            return new FaceGraphicTracker(graphicOverlay, graphic);
        } catch (Exception ex) {
            Log.d("FaceTrackerFactory", ex.getMessage(), ex);
        }
        return null;
    }
}
