using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Identifier : MonoBehaviour
{
    [SerializeField] float maxtime = 2.0f;

    float startTime;

    Collider col;
    Camera cam;


    void Start()
    {
        cam = GetComponent<Camera>();
    }

    private void Update()
    {
        Identify();
    }

    void Identify()
    {
        Ray ray = cam.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            if (hit.collider == col)
            {
                if (startTime + maxtime > Time.time)
                {
                    Debug.Log("hit fo sm");
                }
            }
            else
            {
                startTime = Time.time;
                col = hit.collider;
            }
        }
        else
        {
            startTime = 0.0f;
            col = null;
        }
    }
}
