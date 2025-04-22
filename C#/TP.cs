using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TP : MonoBehaviour
{
    Control control;
    private void Awake()
    {
        control = FindFirstObjectByType<Control>();
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            control.PlayerGame();
            control.LoadGame(2);
        }
    }
}
