using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnProjectiles : MonoBehaviour
{
    public GameObject firePoint;
    public List<GameObject> vfx = new List<GameObject>();
    [SerializeField] Transform ship;
    [SerializeField] SoundManager soundManager;

    private GameObject effectToSpawn;

    private float timeToFire = 0;


    void Start()
    {
        effectToSpawn = vfx[0];
    }

    void FixedUpdate()
    {
        // if left click and check for fire rate
        if (Input.GetMouseButton(0) && Time.time >= timeToFire)
        {
            timeToFire = Time.time + 1 / effectToSpawn.GetComponent<MoveProjectile>().fireSpeed;
            SpawnVFX();
        }
        else if(Input.GetMouseButton(0))
        {
            soundManager.PlayGunSound();
        }
        else
        {
            soundManager.StopGunSound();
        }
        //firePoint.gameObject.transform.rotation = rotatetoMouse.GetRotation();
    }

    void SpawnVFX()
    {
        if (firePoint != null)
        {
            // create projectile
            Instantiate(effectToSpawn, transform.position, ship.transform.rotation);
            //newBullet.GetComponent<Rigidbody>().velocity = transform.forward * newBullet.GetComponent<MoveProjectile>().speed; // give the bullets some init velocity

        }
    }
}
