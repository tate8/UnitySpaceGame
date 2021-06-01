using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawnProjectile : MonoBehaviour
{
    // same as SpawnProjectile, but handles enemy bullets
    //TODO: make SpawnProjectile handle both player and enemy bullets

    [SerializeField] GameObject enemy;
    public GameObject firePoint;
    public List<GameObject> vfx = new List<GameObject>();
    public EnemyRotateToPlayer rotateToPlayer;
    Quaternion enemyRotation;

    private GameObject effectToSpawn;
    private float timeToFire = 0;

    void Start()
    {
        effectToSpawn = vfx[0];
    }

    public void FireProjectile()
    {
        if (Time.time >= timeToFire)
        {
            enemyRotation = enemy.transform.rotation;
            timeToFire = Time.time + 1 / effectToSpawn.GetComponent<MoveEnemyProjectile>().fireSpeed;
            SpawnVFX(enemyRotation);
        }
        
    }

    void SpawnVFX(Quaternion enemyRotation)
    {
        if (firePoint != null)
        {
            Instantiate(effectToSpawn, firePoint.transform.position, enemyRotation);
        }
    }
}
