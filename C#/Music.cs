using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class Music : MonoBehaviour
{
    [Header("请保证播放音乐的物体名称为：Music")]
    private AudioSource audioSource;
    public AudioMixer audioMixer;
    float musicSize = 0;
    float yinXiaoSize = 0;
    // Start is called before the first frame update
    private void Awake()
    {
        try
        {
            audioSource = GameObject.Find("Music").GetComponent<AudioSource>();
        }
        catch
        {
            Debug.LogError("请保证播放音乐的物体名称为：Music");
        }
        
    }
    void Start()
    {
        audioMixer.SetFloat("Music", musicSize);
        audioMixer.SetFloat("YinXiao", yinXiaoSize);

        audioSource.Play();
    }

    // 供编辑器调用的方法
    public void ApplySliderValue(float value,float value2)
    {
        musicSize = value;
        yinXiaoSize = value2;
    }
}
