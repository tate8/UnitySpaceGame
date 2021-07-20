using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Speedometer : MonoBehaviour
{
    [SerializeField] Rigidbody rb;
    [SerializeField] Text speedText;
    public float speed;

    private void Start()
    {
        rb = transform.GetComponent<Rigidbody>();
    }

    void FixedUpdate()
    {
        speed = rb.velocity.magnitude;
        speedText.text = "Speed: " + (int)speed + "m/s";
    }
}
