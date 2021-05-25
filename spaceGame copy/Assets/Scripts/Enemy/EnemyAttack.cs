using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAttack : MonoBehaviour
{
    [SerializeField] GameObject target;
    [SerializeField] EnemySpawnProjectile projectile;
    [SerializeField] GameObject player;

    private void Update()
    {
        if (!FindTarget())
            return;
        InFront();
        HaveLineOfSight();

        if (InFront() && HaveLineOfSight())
        {
            FireLaser();
        }
    }


    bool InFront()
    {
        Vector3 directionToTarget = transform.position - target.transform.position;
        float angle = Vector3.Angle(transform.forward, directionToTarget);

        // if in range
        if (Mathf.Abs(angle) > 30 && Mathf.Abs(angle)<330)
        {
            return true;
        }
        else
            return false;
    }


    bool HaveLineOfSight()
    {
        RaycastHit hit;
        Vector3 direction = target.transform.position - transform.position;

        if (Physics.Raycast(projectile.transform.position, direction, out hit, 10000))
        {
            return true;
        }
        else
            return false;

    }

    void FireLaser()
    {
        projectile.FireProjectile();
    }

    bool FindTarget()
    {
        if (target == null)
            target = GameObject.FindGameObjectWithTag("Player");
        if (target == null)
            return false;
        else
            return true;
    }
}
