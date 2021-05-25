using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Planet : MonoBehaviour
{
    [Range(2, 256)]
    public int resolution = 10;

    [SerializeField, HideInInspector]
    MeshFilter[] meshFilters;
    TerrainFace[] terrainFaces;

    private void OnValidate()
    {
        Initialize();
        GenerateMesh();
    }

    void Initialize()
    {
        // only crate new mesh filters if its empty
        if (meshFilters == null || meshFilters.Length == 0)
        {
            meshFilters = new MeshFilter[6];
        }
        terrainFaces = new TerrainFace[6];

        // vector 3 array of all the directions
        Vector3[] direction = { Vector3.up, Vector3.down, Vector3.left, Vector3.right, Vector3.forward, Vector3.back };
        // for each side of cube
        for (int i=0; i < 6; i++)
        {
            if (meshFilters[i] == null)
            {
                // make mesh and mesh renderer so u can see it
                GameObject meshObj = new GameObject("mesh");
                meshObj.transform.parent = transform;

                //set default material to standard
                meshObj.AddComponent<MeshRenderer>().sharedMaterial = new Material(Shader.Find("Standard"));
                meshFilters[i] = meshObj.AddComponent<MeshFilter>();
                meshFilters[i].sharedMesh = new Mesh();
            }
            // create all terrain faces taking the mesh, resolution, and local up
            terrainFaces[i] = new TerrainFace(meshFilters[i].sharedMesh, resolution, direction[i]);
        }
    }

    void GenerateMesh()
    {
        foreach(TerrainFace face in terrainFaces)
        {
            // make mesh for all faces (6)
            face.ConstructMesh();
        }
    }
}
