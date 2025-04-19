#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class MusicEditor : MonoBehaviour
{

[CustomEditor(typeof(Music))]
public class ExampleComponentEditor : Editor
{
        private float sliderValue = 0.5f;
        private float sliderValue2 = 0.5f;

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            // 添加滑动条
            sliderValue = EditorGUILayout.Slider("音乐音量大小", sliderValue, -80, 20);
            sliderValue2 = EditorGUILayout.Slider("音效音量大小", sliderValue2, -80, 20);

            // 实时应用值到目标组件
            Music component = (Music)target;
            component.ApplySliderValue(sliderValue,sliderValue2);
        }
    }
}
#endif
