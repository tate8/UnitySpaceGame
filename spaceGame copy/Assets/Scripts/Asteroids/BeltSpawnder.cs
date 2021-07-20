using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeltSpawnder : MonoBehaviour
{
    [Header("Spawner Settings")]
    public GenericObjectPool pool;
    public GameObject[] prefabs;
    public int asteroidDensity;
    public int seed;
    public float innerRadius;
    public float outerRadius;
    public float height;
    public bool rotatingClockwise;

    [Header("Asteroid Settings")]
    public float minOrbitSpeed;
    public float maxOrbitSpeed;
    public float minRotationSpeed;
    public float maxRotationSpeed;
    public float minScale;
    public float maxScale;


    private Vector3 localPosition;
    private Vector3 worldOffset;
    private Vector3 worldPosition;
    private float randomRadius;
    private float randomRadian;
    private float x;
    private float y;
    private float z;


    // Random point on circle only given angle
    // x = cx + r * cos(a)
    // y = cy + r * sin(a)
    private void Start()
    {
        Random.InitState(seed);

        for (int i = 0; i < asteroidDensity; i++)
        {
            do
            {
                randomRadius = Random.Range(innerRadius, outerRadius);
                randomRadian = Random.Range(0, (2 * Mathf.PI));

                y = Random.Range(-(height / 2), (height / 2));
                x = randomRadius * Mathf.Cos(randomRadian);
                z = randomRadius * Mathf.Sin(randomRadian);
            }
            while (float.IsNaN(z) && float.IsNaN(x));

            localPosition = new Vector3(x, y, z);
            worldOffset = transform.rotation * localPosition;
            worldPosition = transform.position + worldOffset;

            //GameObject _asteroid = pool.Instantiate(worldPosition, Quaternion.Euler(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360)));
            GameObject randomPrefab = prefabs[Random.Range(0, prefabs.Length)];
            GameObject _asteroid = Instantiate(randomPrefab, worldPosition, Quaternion.Euler(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360)));
            _asteroid.AddComponent<BeltObject>().SetupBeltObject(Random.Range(minOrbitSpeed, maxOrbitSpeed), Random.Range(minRotationSpeed, maxRotationSpeed), gameObject, rotatingClockwise);
            _asteroid.transform.SetParent(transform);
            Vector3 scale = Vector3.one;

            // RANDOM SCALE
            scale.x = Random.Range(minScale, maxScale);
            scale.y = scale.x;
            scale.z = scale.x;
            _asteroid.transform.localScale = scale;
        }
    }
    }

