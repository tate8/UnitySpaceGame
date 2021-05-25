using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shield : MonoBehaviour
{
    [SerializeField] int maxHealth = 10;
    [SerializeField] int currentHealth;
    [SerializeField] float regenRate = 2f;
    [SerializeField] int regenAmount = 1;

    private void Start()
    {
        currentHealth = maxHealth;
        InvokeRepeating("Regenerate", regenRate, regenRate);
    }

    void Regenerate()
    {
        if (currentHealth < maxHealth)
            currentHealth += regenAmount;
        if (currentHealth > maxHealth)
            currentHealth = maxHealth;
    }

    public void TakeDamage(int dmg = 1)
    {
        currentHealth -= dmg;
        if (currentHealth < 1)
            Debug.Log("Im Dead");
    }
}
