using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnPulseBeam : MonoBehaviour
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

    void Update()
    {
        // if left click and check for fire rate
        if (Input.GetMouseButton(1) && Time.time >= timeToFire)
        {
            timeToFire = Time.time + 1 / effectToSpawn.GetComponent<MoveProjectile>().fireSpeed;
            SpawnVFX();
        }
    }

    void SpawnVFX()
    {
        if (firePoint != null)
        {
            // create projectile
            Instantiate(effectToSpawn, firePoint.transform.position, ship.transform.rotation);
        }
    }
}
