using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AsteroidManager : MonoBehaviour
{
    [SerializeField] Asteroid asteroid;
    int numOfAsteroidsOnAxis = 5;
    int gridSpacing = 100;

    void Start()
    {
        //PlaceAsteroids();
    }

    void OnEnable()
    {
        EventManager.onStartGame += PlaceAsteroids;
    }

    void OnDisable()
    {
        EventManager.onStartGame -= PlaceAsteroids;
    }

    void PlaceAsteroids()
    {
        for (int x=0; x<numOfAsteroidsOnAxis; x++)
        {
            for(int y = 0; y < numOfAsteroidsOnAxis; y++)
            {
                for (int z = 0; z < numOfAsteroidsOnAxis; z++)
                {
                    InstantiateAsteroid(x, y, z);
                }
            }
        }
    }

    void InstantiateAsteroid(int x, int y, int z)
    {
        Instantiate(asteroid,
                    new Vector3(transform.position.x + (x * gridSpacing + AsteroidOffset()),
                                transform.position.y + (y * gridSpacing + AsteroidOffset()),
                                transform.position.z + (z * gridSpacing + AsteroidOffset())),
                                Quaternion.identity,
                                transform);
    }

    float AsteroidOffset()
    {
        return Random.Range(-gridSpacing / 2f, gridSpacing / 2f);
    }
}
