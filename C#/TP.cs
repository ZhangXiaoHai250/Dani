using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TP : MonoBehaviour
{
    [Header("挂载该脚本的物体请添加触发器")]
    [Header("将物体名字设置成场景索引")]
    [Header("在标签为Player的物体接触后即可切换场景")]
    [Header("懂了你就打勾\\n")]
    public bool yes;
    Control control;
    Vector3 vectorStart;
    string name;

    private void Awake()
    {
        control = FindFirstObjectByType<Control>();
        name = gameObject.name;
    }
    private void Start()
    {
        try
        {
            vectorStart = GameObject.FindGameObjectWithTag("Player").transform.position;
            vectorStart.y += 20;
        }
        catch
        {
            Debug.Log("没有玩家");
        }
    }
    private void FixedUpdate()
    {
        if (name != gameObject.name)
        {
            TP_01();
            name = gameObject.name;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            TP_01();
        }
    }
    void TP_01()
    {
        int number = -1;

        switch (gameObject.name)
        {
            case "0": number = 0; break;
            case "1": number = 1; break;
            case "2": number = 2; break;
                //default: StartCoroutine(enumerator(other.gameObject)); return;
        }
        if (number < 0) return;
        control.PlayerGame();
        control.LoadGame(number);
    }
    IEnumerator enumerator(GameObject game)
    {
        game.GetComponent<CharacterController>().enabled = false;
        game.transform.position = vectorStart;
        Debug.Log(vectorStart);
       yield return new WaitForSecondsRealtime(0.5f);
        game.GetComponent<CharacterController>().enabled = true;
    }
}
