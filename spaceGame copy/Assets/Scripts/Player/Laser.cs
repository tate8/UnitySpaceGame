using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(LineRenderer))]
public class Laser : MonoBehaviour
{
    [Header("Laser Settings")]
    [SerializeField] Transform laserEffect;
    [SerializeField] SoundManager soundManager;
    [SerializeField] SwitchLockOnZone switchUIColor;

    [SerializeField] float chargeUpTime = 0.5f;
    [SerializeField] float maxDistance = 300f;
    [SerializeField] float laserOnTime = 3f;
    [SerializeField] float laserOffTime = 5f;

    IEnumerator laserBlastCoroutine;
    bool canFire;
    bool rayCastLaser;


    private void Start()
    {
        switchUIColor.TurnRed(); // default UI circle to red

        rayCastLaser = false;
        canFire = true;
    }

    private void Update()
    {
        if(Input.GetMouseButtonDown(1) && !rayCastLaser && canFire)
        {
            laserBlastCoroutine = HandleLaserBlast(chargeUpTime);
            StartCoroutine(laserBlastCoroutine);
        }
        if(rayCastLaser) { // while the laser is on: keep on raycasting and making explosions
            Vector3 rayHitObject = CastRay();
            FireLaser(rayHitObject, null);
        }

        HandleUI();

    }
    IEnumerator HandleLaserBlast(float waitTime)
    {
        soundManager.PlayLaserSound();

        yield return new WaitForSeconds(waitTime); // play sound and then wait for charge up time

        rayCastLaser = true;
        Instantiate(laserEffect, transform);
        Invoke("TurnOffLaser", laserOnTime); // turn off laser after laserOnTime is over
    }

    void HandleUI()
    {
        if (canFire)
        {
            switchUIColor.SetActive(true);
        }
        else
        {
            switchUIColor.SetActive(false);
        }
    }

    Vector3 CastRay()
    {

        RaycastHit hit;
        Vector3 fwd = transform.TransformDirection(Vector3.forward) * maxDistance;
        // if the ray hits something...
        if (Physics.Raycast(transform.position, fwd, out hit))
        {
            Debug.Log("Hit: " + hit.transform.name);
            SpawnExplosion(hit.point, hit.transform);

            if (hit.transform.gameObject.CompareTag("Enemy")) // destroy enemy if it hits them
            {
                foreach (Transform child in hit.transform)
                    Destroy(child.gameObject);
                Destroy(hit.transform.gameObject);
            }
            return hit.point;
        }
        return transform.position + (transform.forward * maxDistance);
    }


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
            canFire = false;
            Invoke("CanFire", laserOffTime); // turn on canFire after cooldown time

        }
    }

    void TurnOffLaser()
    {
        Destroy(transform.GetChild(0).gameObject); // destroy laser prefab
        soundManager.StopLaserSound();
        rayCastLaser = false;

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
