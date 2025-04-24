using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class Interaction : MonoBehaviour
{
    [Header("ʹ�øýű����ڹ��ص�UI����Ӱ�ť\\n�����ڰ�ť���¼�����ӡ�Interactions()������\\nUI����λ�����κ�Ҫ��")]
    [Header("\"�������������ϵ�UI��������ʾ������Ϣ\"")]
    public GameObject ui;
    [Header("�������������ϵ�Text��������ʾ������Ϣ")]
    public Text text;
    List<string> name = new (){ "TP-UI","TP-Game"};
    GameObject games;
    private void Start()
    {
        ui.SetActive(false);
        text.enabled = false;
        foreach (string a in name)
        {
            Debug.Log(a);
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (name.Contains(other.name))
        {
            games = other.gameObject;
            ui.SetActive(true);
            text.enabled = true;
            Text_();
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (name.Contains(other.name))
        {
            games = null;
            ui.SetActive(false);
            text.enabled = false;
        }
    }
    public void Interactions()
    {
        if (games == null) return;
        switch (games.name)
        {
            case "TP-UI": 
                games.name = "0"; 
                ui.GetComponent<Canvas>().enabled = false;
                break;
            case "TP-Game": 
                games.name = "2"; 
                ui.GetComponent<Canvas>().enabled = false; 
                break;
        }
    }
    void Text_()
    {
        switch (games.name)
        {
            case "TP-UI":text.text = "�������ǰ����Ϸ�˵�!";break;
            case "TP-Game": text.text = "�������ǰ����Ϸ!"; break;
        }
    }
}
