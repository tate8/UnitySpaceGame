using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class shipMovement : MonoBehaviour
{

    [SerializeField] Thruster[] thruster;
    [SerializeField] ParticleSystem slowSpeedParticles;
    [SerializeField] ParticleSystem[] warpSpeedParticles;
    [SerializeField] SoundManager soundManager;

    bool limitLookingInWarpSpeed = false;
    Rigidbody rb;

    //[Header("General Settings")]
    //public float forwardSpeed = 25f, strafeSpeed = 7.5f, hoverSpeed = 10f;
    //public float forwardAcceleration = 2.5f, strafeAcceleration = 2f, hoverAcceleration = 4f;
    //private float activeForwardSpeed, activeStrafeSpeed, activeHoverSpeed;

    [Header("Look Settings")]
    public float lookRateSpeed = 90f;
    private Vector2 lookInput, screenCenter, mouseDistance;

    [Header("Roll Settings")]
    public bool controlRollWithMouse = true;
    public bool invertControls = false;
    public float rollSpeed = 90f, rollAcceleration = 3.5f;
    private float rollInput;

    [Header("Handling")]
    [SerializeField] float thrustStrength = 50f;
    [SerializeField] int boostStrength = 50;
    public float maxSpeed = 100;
    Vector3 thrusterInput;


    KeyCode ascendKey = KeyCode.Space;
    KeyCode descendKey = KeyCode.LeftShift;
    KeyCode forwardKey = KeyCode.W;
    KeyCode backwardKey = KeyCode.S;
    KeyCode leftKey = KeyCode.A;
    KeyCode rightKey = KeyCode.D;
    KeyCode boostKey = KeyCode.R;

    //
    [Header("General")]
    public Transform camViewPoint;
    public Transform pilotSeatPoint;

    FirstPersonController pilot;
    bool shipIsPiloted;

    SpawnProjectiles[] spawnProjectilesScipt;
    shipMovement shipMovementScript;
    Laser laserScript;


    private void Start()
    {
        Cursor.visible = true;
        // cache scripts so u can turn them on and off
        shipMovementScript = GetComponent<shipMovement>();
        spawnProjectilesScipt = GetComponentsInChildren<SpawnProjectiles>();
        laserScript = GetComponentInChildren<Laser>();

        laserScript.enabled = false;
        shipMovementScript.enabled = false;
        foreach (SpawnProjectiles gun in spawnProjectilesScipt)
        {
            gun.enabled = false;
        }

        screenCenter.x = Screen.width * 0.5f;
        screenCenter.y = Screen.height * 0.5f;

        Cursor.lockState = CursorLockMode.Confined;

        // stop particle systems
        slowSpeedParticles.Stop();
        foreach(ParticleSystem wp in warpSpeedParticles)
        {
            wp.Stop();
        }
        rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        if (!limitLookingInWarpSpeed)
        {
            LookAtMouse();
        }
        ChangePosition();
        GenerateSlowSpeedParticles();
        DetectKeyPress();


    }
    void FixedUpdate()
    {
        Vector3 gravity = NBodySimulation.CalculateAcceleration(rb.position);
        rb.AddForce(gravity, ForceMode.Acceleration);

        if (rb.velocity.magnitude > maxSpeed)
        {
            rb.velocity = rb.velocity.normalized * maxSpeed;
        }
        Vector3 thrustDir = transform.TransformVector(thrusterInput);

        rb.AddForce(thrustDir * thrustStrength, ForceMode.Acceleration);
    }

    public void TogglePiloting()
    {
        if (shipIsPiloted)
        {
            StopPilotingShip();
        }
        else
        {
            PilotShip();
        }
    }

    public void PilotShip()
    {
        pilot = FindObjectOfType<FirstPersonController>();
        shipIsPiloted = true;
        pilot.Camera.transform.parent = camViewPoint;
        pilot.Camera.transform.localPosition = Vector3.zero;
        pilot.Camera.transform.localRotation = Quaternion.identity;
        pilot.gameObject.SetActive(false);
        // turn on ship controller
        shipMovementScript.enabled = true;
        foreach (SpawnProjectiles gun in spawnProjectilesScipt)
        {
            gun.enabled = true;
        }
        laserScript.enabled = true;
    }

    void StopPilotingShip()
    {
        shipIsPiloted = false;
        pilot.transform.position = pilotSeatPoint.position;
        pilot.transform.rotation = pilotSeatPoint.rotation;
        pilot.Rigidbody.velocity = rb.velocity;
        pilot.gameObject.SetActive(true);
        pilot.ExitFromSpaceship();
        // turn off ship controller
        shipMovementScript.enabled = false;
        foreach (SpawnProjectiles gun in spawnProjectilesScipt)
        {
            gun.enabled = false;
        }
        laserScript.enabled = false;

    }


    void DetectKeyPress()
    {
        // check for keypress
        if (Input.GetKey(ascendKey) || Input.GetKey(descendKey) || Input.GetKey(forwardKey) || Input.GetKey(backwardKey) || Input.GetKey(leftKey) || Input.GetKey(rightKey) || Input.GetKey(boostKey))
        {
            rb.drag = 0.7f;
            soundManager.PlayThrustSound();


        }
        else
        {
            rb.drag = 0f;
            soundManager.StopThrustSound();

        }
    }

    void GenerateSlowSpeedParticles()
    {
        // slow particles for player reference point
        float axis = Input.GetAxis("Vertical");
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
        // THESE CONTROLLS WERE MAKING THE SHIP LAG: WAS USING ADD FORCE ALONG WITH TRANSFORM.ROTATE
        //    if (!invertControls)
        //    {
        //        rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);
        //        transform.Rotate(mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime, Space.Self);
        //    }
        //    else
        //    {
        //        rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);
        //        transform.Rotate(-mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime, Space.Self);
        //    }

        //}
        //else
        //{
        //    if (!invertControls)
        //    {
        //        rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);
        //        transform.Rotate(-mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime, Space.Self);
        //        transform.Rotate(-mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, -mouseDistance.x * rollSpeed * Time.deltaTime, Space.Self);
        //    }
        //    else
        //    {
        //rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);
        //        transform.Rotate(mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime, Space.Self);
        //        transform.Rotate(mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, -mouseDistance.x * rollSpeed * Time.deltaTime, Space.Self);
        //    }
        //}

        //Vector3 torqueVector = new Vector3(mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime);
        //rb.AddTorque(torqueVector);
        rollInput = Mathf.Lerp(rollInput, Input.GetAxisRaw("Roll"), rollAcceleration * Time.deltaTime);
        rb.AddRelativeTorque(-mouseDistance.y * lookRateSpeed * Time.deltaTime, mouseDistance.x * lookRateSpeed * Time.deltaTime, rollInput * rollSpeed * Time.deltaTime);
    }

    private void ChangePosition()
    {
        //activeForwardSpeed = Mathf.Lerp(activeForwardSpeed, Input.GetAxisRaw("Vertical") * forwardSpeed, forwardAcceleration * Time.deltaTime);
        //activeStrafeSpeed = Mathf.Lerp(activeStrafeSpeed, Input.GetAxisRaw("Horizontal") * strafeSpeed, strafeAcceleration * Time.deltaTime);
        //activeHoverSpeed = Mathf.Lerp(activeHoverSpeed, Input.GetAxisRaw("Hover") * hoverSpeed, hoverAcceleration * Time.deltaTime);
        //transform.position += transform.forward * activeForwardSpeed * Time.deltaTime;
        //transform.position += transform.right * activeStrafeSpeed * Time.deltaTime;
        //transform.position += transform.up * activeHoverSpeed * Time.deltaTime;

        // Thruster input
        //int thrustInputX = GetInputAxis(leftKey, rightKey);
        int thrustInputX = 0;
        int thrustInputY = GetInputAxis(descendKey, ascendKey);
        int thrustInputZ = GetInputAxis(backwardKey, forwardKey);

        if (Input.GetKey(boostKey))
        {
            limitLookingInWarpSpeed = true;
            thrustInputZ += boostStrength;
            foreach(ParticleSystem wp in warpSpeedParticles)
            {
                if (!wp.isPlaying)
                {
                    wp.Play();
                }
            }

        }
        else
        {
            limitLookingInWarpSpeed = false;

            foreach (ParticleSystem wp in warpSpeedParticles)
            {
                wp.Stop();
            }
        }

        thrusterInput = new Vector3(thrustInputX, thrustInputY, thrustInputZ);


    }

    int GetInputAxis(KeyCode negativeAxis, KeyCode positiveAxis)
    {
        int axis = 0;
        if (Input.GetKey(positiveAxis))
        {
            axis += 1;
        }
        if (Input.GetKey(negativeAxis))
        {
            axis -= 1;
        }
        return axis;
    }
}