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

            // ��ӻ�����
            sliderValue = EditorGUILayout.Slider("����������С", sliderValue, -80, 20);
            sliderValue2 = EditorGUILayout.Slider("��Ч������С", sliderValue2, -80, 20);

            // ʵʱӦ��ֵ��Ŀ�����
            Music component = (Music)target;
            component.ApplySliderValue(sliderValue,sliderValue2);
        }
    }
}
#endif
