using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Light))]
[RequireComponent(typeof(LineRenderer))]
public class Laser : MonoBehaviour
{
    // NOT IN USE

    [SerializeField] float maxDistance = 300f;
    LineRenderer lr;

    Light laserLight;
    float laserOffTime = 0.1f;
    float fireDelay = 5.0f;
    bool canFire = true;


    private void Awake()
    {
        lr = GetComponent<LineRenderer>();
        laserLight = GetComponent<Light>();
    }

    private void Start()
    {
        lr.enabled = false;
        laserLight.enabled = false;
        canFire = true;
    }

    //private void Update()
    //{
    //    Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) * maxDistance, Color.yellow);
    //}

    Vector3 CastRay()
    {
        RaycastHit hit;
        Vector3 fwd = transform.TransformDirection(Vector3.forward) * maxDistance;
        // if the ray hits something...
        if (Physics.Raycast(transform.position, fwd, out hit))
        {
            Debug.Log("Hit: " + hit.transform.name);

            SpawnExplosion(hit.point, hit.transform);

            return hit.point;
        }
        return transform.position + (transform.forward * maxDistance);
    }

    //public void FireLaser()
    //{
        
    //}

    void SpawnExplosion(Vector3 hitPosition, Transform target)
    {
        Explosion temp = target.transform.GetComponent<Explosion>();
        if (temp != null)
        {
            temp.AddForce(hitPosition, transform);
        }
    }

    public void FireLaser(Vector3 targetPosition, Transform target)
    {
        if (canFire)
        {
            if (target != null)
            {
                SpawnExplosion(targetPosition, target);
            }
            // if can fire, set start and end pos
            lr.SetPosition(0, transform.position);
            lr.SetPosition(1, targetPosition);
            lr.enabled = true;
            laserLight.enabled = true;
            Invoke("TurnOffLaser", laserOffTime);
            Invoke("CanFire", fireDelay);
            canFire = false;
        }
    }

    void TurnOffLaser()
    {
        lr.enabled = false;
        laserLight.enabled = false;
    }

    public float Distance
    {
        get{ return maxDistance; }
    }

    void CanFire()
    {
        canFire = true;
    }

}
