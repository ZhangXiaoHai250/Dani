using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    public float speed = 5;
    public float g = -4;
    VariableJoystick variableJoystick;
    CharacterController characterController;
    private void Start()
    {
        variableJoystick = FindAnyObjectByType<VariableJoystick>();
        characterController = GetComponent<CharacterController>();
    }

    public void FixedUpdate()
    {
        if (characterController.enabled == false) return;
        Vector3 direction = Vector3.zero;
        if (characterController.isGrounded)
        {
            direction = Vector3.forward * variableJoystick.Vertical + Vector3.right * variableJoystick.Horizontal;
        }
        direction.y = g;
        characterController.Move(direction * speed * Time.fixedDeltaTime);
    }
}
