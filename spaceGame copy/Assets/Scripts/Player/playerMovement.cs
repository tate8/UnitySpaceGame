using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerMovement : MonoBehaviour
{
    // FOR WALKING PLAYER

    Animator anim;
    CharacterController controller;

    float speed = 3f;
    float rotSpeed = 150;
    float rot = 0;
    float gravity = 8;

    Vector3 moveDir = Vector3.zero;

    private void Start()
    {
        // cache
        anim = GetComponent<Animator>();
        controller = GetComponent<CharacterController>();
    }

    void Update()
    {
        GetKeyInput();
    }

    private void GetKeyInput()
    {
        if (controller.isGrounded)
        {
            // if W presssed, move and play animation
            if (Input.GetKey(KeyCode.W))
            {
                anim.SetBool("isRunning", true);
                anim.SetBool("isIdle", false);
                moveDir = new Vector3(0, 0, 1);
                moveDir *= speed;
                moveDir = transform.TransformDirection(moveDir);

                rot += Input.GetAxis("Horizontal") * rotSpeed * Time.deltaTime;
                transform.eulerAngles = new Vector3(0, rot, 0);
            }
            else
            {
                anim.SetBool("isRunning", false);
                anim.SetBool("isIdle", true);
                moveDir = new Vector3(0, 0, 0);
            }
        }

        

        moveDir.y -= gravity * Time.deltaTime;
        controller.Move(moveDir * Time.deltaTime);


            //if (Input.GetKey(KeyCode.W))
            //{
            //    
            //}
            //else if (Input.GetKey(KeyCode.A))
            //{
            //    anim.SetBool("isRunning", true);
            //    anim.SetBool("isIdle", false);
            //}
            //else if (Input.GetKey(KeyCode.S))
            //{
            //    anim.SetBool("isRunning", true);
            //    anim.SetBool("isIdle", false);
            //}
            //else if (Input.GetKey(KeyCode.D))
            //{
            //    anim.SetBool("isRunning", true);
            //    anim.SetBool("isIdle", false);
            //}
            //else
            //{
            //    anim.SetBool("isRunning", false);
            //    anim.SetBool("isIdle", true);

            //}
        
    }
}

