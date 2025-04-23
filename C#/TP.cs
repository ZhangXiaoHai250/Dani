using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TP : MonoBehaviour
{
    Control control;
    Vector3 vectorStart;
    
    private void Awake()
    {
        control = FindFirstObjectByType<Control>();
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
            Debug.Log("Ã»ÓÐÍæ¼Ò");
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            int number = 0;

            switch (gameObject.name)
            {
                case "0": number = 0; break;
                case "1": number = 1; break;
                case "2": number = 2; break;
                //default: StartCoroutine(enumerator(other.gameObject)); return;
            }

            control.PlayerGame();
            control.LoadGame(number);
        }
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
