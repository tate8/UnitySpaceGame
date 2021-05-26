using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnProjectiles : MonoBehaviour
{
    public GameObject firePoint;
    public List<GameObject> vfx = new List<GameObject>();
    public RotateToMouse rotatetoMouse;
    [SerializeField] Transform ship;

    private GameObject effectToSpawn;

    private float timeToFire = 0;


    void Start()
    {
        effectToSpawn = vfx[0];
    }

    void Update()
    {
        if (Input.GetMouseButton(0) && Time.time >= timeToFire)
        {
            timeToFire = Time.time + 1 / effectToSpawn.GetComponent<MoveProjectile>().fireSpeed;
            SpawnVFX();
        }
        //firePoint.gameObject.transform.rotation = rotatetoMouse.GetRotation();
    }

    void SpawnVFX()
    {
        GameObject vfx;
        if (firePoint != null)
        {
            vfx = Instantiate(effectToSpawn, firePoint.transform.position, ship.transform.rotation);
            if(rotatetoMouse != null)
            {
                //vfx.transform.localRotation = rotatetoMouse.GetRotation();

            }
        }
    }
}
