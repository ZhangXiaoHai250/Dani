using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class Music : MonoBehaviour
{
    [Header("�뱣֤�������ֵ���������Ϊ��Music")]
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
            Debug.LogError("�뱣֤�������ֵ���������Ϊ��Music");
        }
        
    }
    void Start()
    {
        audioMixer.SetFloat("Music", musicSize);
        audioMixer.SetFloat("YinXiao", yinXiaoSize);

        audioSource.Play();
    }

    // ���༭�����õķ���
    public void ApplySliderValue(float value,float value2)
    {
        musicSize = value;
        yinXiaoSize = value2;
    }
}
