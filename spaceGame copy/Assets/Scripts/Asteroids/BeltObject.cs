using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeltObject : MonoBehaviour
{
    [Header("LOD Settings")]
    public GameObject physicalBody;
    public float lodCreateDistance = 3000;
    public float lodDestroyDistance = 3250;

    [SerializeField] private float orbitSpeed;
    [SerializeField] private GameObject parent;
    [SerializeField] private bool rotateClockwise;
    [SerializeField] private float rotationSpeed;
    [SerializeField] private Vector3 rotationDirection;

    private GameObject asteroid;


    public void SetupBeltObject(float _speed, float _rotationSpeed, GameObject _parent, bool _rotateClockwise)
    {
        orbitSpeed = _speed;
        rotationSpeed = _rotationSpeed;
        parent = _parent;
        rotateClockwise = _rotateClockwise;
        rotationDirection = new Vector3(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360));
    }

    private void Start()
    {
        // cache
        asteroid = transform.gameObject;
    }

    private void Update()
    {

        //HandleBoxCollider();

        //HandleRotation();

    }

    void HandleBoxCollider()
    {
        //var difference = transform.position - Camera.main.transform.position;
        float difference = Vector3.Distance(Camera.main.transform.position, transform.position);
       
        if (asteroid.GetComponent<Rigidbody>())
        {
            // if they have a box collider, check for distance from cam and do stuff accordingly
            if (difference > lodDestroyDistance)
            {
                Destroy(asteroid.GetComponent<Rigidbody>());
                Destroy(asteroid.GetComponent<MeshCollider>());
                if (asteroid.GetComponent<Explosion>() != null)
                    Destroy(asteroid.GetComponent<Explosion>());
            }
            else
                return;
        }
        else
        {
            // if they don't have one, check if you need to create one
            if (difference < lodCreateDistance)
            {
                // add box collider if lodCreateDistance from cam
                asteroid.AddComponent<MeshCollider>();
                Rigidbody rb = asteroid.AddComponent<Rigidbody>();
                // turn off gravity
                rb.useGravity = false;
                // MAKING THE GAME LAG: FIX LATER
                Explosion exp = asteroid.AddComponent<Explosion>();
                exp.explosion = GameObject.Find("Explosion");
                exp.rigidBody = rb;
            }
            else
                return;
        }
    }

    void HandleRotation()
    {
        if (rotateClockwise)
        {
            transform.RotateAround(parent.transform.position, parent.transform.up, orbitSpeed * Time.deltaTime);
        }
        else
        {
            transform.RotateAround(parent.transform.position, -parent.transform.up, orbitSpeed * Time.deltaTime);
        }

        transform.Rotate(rotationDirection, rotationSpeed * Time.deltaTime);
    }
}


//if (physicalBody == null)
//{
//    var difference = physicalBody.transform.position - Camera.main.transform.position;
//    if (difference.magnitude < lodCreateDistance)
//    {
//        var gobj = (GameObject)Instantiate(prefab, transform.position, transform.rotation);
//        gobj.transform.localScale = transform.localScale;
//        var rigidBody = gobj.GetComponent<Rigidbody>();
//        gobj.transform.parent = this.transform;
//        physicalBody = gobj;
//    }
//    else
//    {

//}
//else
//{
//    var difference = physicalBody.transform.position - Camera.main.transform.position;
//    if(difference.magnitude > lodDestroyfDistance)
//    {
//        transform.position = physicalBody.transform.position;
//        transform.rotation = physicalBody.transform.rotation;
//        var rigidBody = physicalBody.GetComponent<Rigidbody>();
//        orbitSpeed = rigidBody.velocity.magnitude;

//        Destroy(physicalBody);
//        physicalBody = null;
//    }
//}


