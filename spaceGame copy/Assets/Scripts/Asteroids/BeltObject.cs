using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeltObject : MonoBehaviour
{
    //[Header("LOD Settings")]
    //public GameObject physicalBody;
    //public float lodCreateDistance = 100;
    //public float lodDestroyfDistance = 250;
    //public GameObject prefab;

    [SerializeField] private float orbitSpeed;
    [SerializeField] private GameObject parent;
    [SerializeField] private bool rotateClockwise;
    [SerializeField] private float rotationSpeed;
    [SerializeField] private Vector3 rotationDirection;



    public void SetupBeltObject(float _speed, float _rotationSpeed, GameObject _parent, bool _rotateClockwise)
    {
        orbitSpeed = _speed;
        rotationSpeed = _rotationSpeed;
        parent = _parent;
        rotateClockwise = _rotateClockwise;
        rotationDirection = new Vector3(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360));
    }


    private void Update()
    {
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



    }

