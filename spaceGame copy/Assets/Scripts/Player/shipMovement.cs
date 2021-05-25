using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class shipMovement : MonoBehaviour
{

    [SerializeField] Thruster[] thruster;
    [SerializeField] ParticleSystem slowSpeedParticles;


    public float forwardSpeed = 25f, strafeSpeed = 7.5f, hoverSpeed = 10f;
    private float activeForwardSpeed, activeStrafeSpeed, activeHoverSpeed;
    private float forwardAcceleration = 2.5f, strafeAcceleration = 2f, hoverAcceleration = 4f;

    public float lookRateSpeed = 90f;
    private Vector2 lookInput, screenCenter, mouseDistance;

    private float rollInput;
    public float rollSpeed = 90f, rollAcceleration = 3.5f;
   

    private void Start()
    {
        screenCenter.x = Screen.width * 0.5f;
        screenCenter.y = Screen.height * 0.5f;

        Cursor.lockState = CursorLockMode.Confined;
        slowSpeedParticles.Stop();
    }

    private void Update()
    {
        LookAtMouse();
        ChangePosition();
        GenerateSlowSpeedParticles();
    }


    void GenerateSlowSpeedParticles()
    {
        float axis = Input.GetAxis("Vertical");
        Debug.Log(axis);
        if (axis > 0 && !slowSpeedParticles.isPlaying)
        {
            slowSpeedParticles.Play();
        }
        else if (axis<=0)
        {
            slowSpeedParticles.Stop();
            //slowSpeedParticles.Clear();
        }
    }

    private void LookAtMouse()
    {
        lookInput.x = Input.mousePosition.x;
        lookInput.y = Input.mousePosition.y;

        mouseDistance.x = (lookInput.x - screenCenter.x) / screenCenter.x;
        mouseDistance.y = (lookInput.y - screenCenter.y) / screenCenter.y;

        mouseDistance = Vector2.ClampMagnitude(mouseDistance, 2f);
        rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);

        transform.Rotate(-mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime, Space.Self);
    }

    private void ChangePosition()
    {
        // if start to thrust, call Thruster.activate(), else call Thruster.activate(false)
        //if (Input.GetKeyDown(KeyCode.W))
        //{
        //    foreach (Thruster t in thruster)
        //    {
        //        t.Activate();
        //    }
        //}
        //else if (Input.GetKeyUp(KeyCode.W))
        //{
        //    foreach (Thruster t in thruster)
        //    {
        //        t.Activate(false);
        //    }
        //}
        if (Input.GetAxis("Vertical") > 0)
        {
            foreach (Thruster t in thruster)
            {
                t.Intensity(Input.GetAxis("Vertical"));
            }
        }

        activeForwardSpeed = Mathf.Lerp(activeForwardSpeed, Input.GetAxisRaw("Vertical") * forwardSpeed, forwardAcceleration * Time.deltaTime);
        activeStrafeSpeed = Mathf.Lerp(activeStrafeSpeed, Input.GetAxisRaw("Horizontal") * strafeSpeed, strafeAcceleration * Time.deltaTime);
        activeHoverSpeed = Mathf.Lerp(activeHoverSpeed, Input.GetAxisRaw("Hover") * hoverSpeed, hoverAcceleration * Time.deltaTime);

        // slow down if going backwards
        //if (Input.GetAxis("Vertical") > 0)
        //{
        //    activeForwardSpeed -= 5;
        //}
        transform.position += transform.forward * activeForwardSpeed * Time.deltaTime;
        transform.position += transform.right * activeStrafeSpeed * Time.deltaTime;
        transform.position += transform.up * activeHoverSpeed * Time.deltaTime;

    }
}