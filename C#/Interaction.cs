using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class Interaction : MonoBehaviour
{
    [Header("使用该脚本请在挂载的UI下添加按钮\\n并且在按钮的事件中添加“Interactions()”方法\\nUI放置位置无任何要求")]
    [Header("\"挂载在人物身上的UI，用于显示互动信息\"")]
    public GameObject ui;
    [Header("挂载在人物身上的Text，用于显示互动信息")]
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
            case "TP-UI":text.text = "点击互动前往游戏菜单!";break;
            case "TP-Game": text.text = "点击互动前往游戏!"; break;
        }
    }
}
