using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnMissile : MonoBehaviour
{
    public GameObject firePoint;
    public List<GameObject> vfx = new List<GameObject>();
    [SerializeField] Transform ship;
    [SerializeField] float rayLength = 200;
    [SerializeField] float sphereRadius = 2.5f;
    [SerializeField] SwitchLockOnZone switchUIColor;

    private GameObject target;
    private GameObject missile;
    private GameObject effectToSpawn;
    private IEnumerator coroutine;
    private bool lockOn;
    private float timeToFire;


    void Start()
    {
        effectToSpawn = vfx[0];
        coroutine = RemoveUIBox(5.0f);
    }

    void Update()
    {
        LockedOn();

        // press mouse button to shoot
        if (Input.GetMouseButton(1) && lockOn && LockedOn()!=null && Time.time >= timeToFire)
        {
            timeToFire = Time.time + 1 / effectToSpawn.GetComponent<MoveMissile>().fireSpeed;
            SpawnVFX(target);
        }
        //firePoint.gameObject.transform.rotation = rotatetoMouse.GetRotation();
    }

    void SpawnVFX(GameObject target)
    {
        if (firePoint != null)
        {
            missile = Instantiate(effectToSpawn, firePoint.transform.position, ship.transform.rotation);
            // give the missle a target of whatever the sphere hits
            missile.GetComponent<MoveMissile>().target = target;
        }
    }

    GameObject LockedOn()
    {
        // send sphere out and if it hits, turn the lock on UI red, else white
        Vector3 fwd = transform.TransformDirection(Vector3.forward);
        RaycastHit hit;

        if (Physics.SphereCast((transform.position + new Vector3(0,0,10)), sphereRadius, fwd, out hit, rayLength) && !hit.transform.CompareTag("Player"))
        {
            target = hit.collider.gameObject;
            // if the sphere hits enemy (actually the enemy mesh), enabled the canvas
            if (target.CompareTag("Enemy"))
            {
                target.GetComponentInChildren<Canvas>().enabled = true;
                // start coroutine  to disable it
                StartCoroutine(coroutine);
            }

            switchUIColor.SetActive(true);
            lockOn = true;
            switchUIColor.TurnRed();
            return target;
        }
        else
        {
            switchUIColor.SetActive(false);
            //if (target.CompareTag("Enemy"))
            //    target.GetComponent<Canvas>().enabled = false;
            switchUIColor.TurnWhite();
            return null;
        }
    }

    IEnumerator RemoveUIBox(float waitTime)
    {
        // disable canvas if it's been waitTime seconds
        yield return new WaitForSeconds(waitTime);
        //if(target!=null)
            target.GetComponentInChildren<Canvas>().enabled = false;
    }
}
