using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

public class Move : MonoBehaviour
{
    public float speed = 5;
    public float rotationSpeed = 5;
    public float gravity = -4;
    VariableJoystick variableJoystick;
    CharacterController characterController;
    private bool isGrounded;
    Vector3 direction;
    int currentSceneIndex;
    private void Start()
    {
        currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        try
        {
            variableJoystick = FindAnyObjectByType<VariableJoystick>();
        }
        catch
        {
            Debug.LogError("请确保你添加了摇杆预制体在场景当中,预制体路径:Assets/Joystick Pack/Prefabs/Variable Joystick.prefab");
        }
        
        characterController = GetComponent<CharacterController>();
        direction = Vector3.zero;
    }

    public void FixedUpdate()
    {
        isGrounded = characterController.isGrounded;
        if (characterController.enabled == false) return;
        
        if (isGrounded)
        {
            if(currentSceneIndex != 1)
            {
                direction = Vector3.forward * variableJoystick.Vertical + Vector3.right * variableJoystick.Horizontal;
            }
            else
            {
                direction = Vector3.right * variableJoystick.Horizontal;
            }
        }
        direction.y = gravity;
        characterController.Move(direction * speed * Time.fixedDeltaTime);

        Vector3 vector = new Vector3(direction.x + transform.forward.x, 0 , direction.z + transform.forward.z);
        Quaternion targetRotation = Quaternion.LookRotation(vector);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
    }
}
