#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

// Reads line having this format: <X Y Z color>
// Creates prefabs made of cubes. One cube is defined by its coordinates and its color.
// Colors are interpreted as seprate materials.
// Tested with Goxel 0.8.0.
public class ParseVoxelStructure : MonoBehaviour
{
	struct RawVoxelData
	{
		public Vector3 position;
		public string color;

		public RawVoxelData(Vector3 position, string color)
		{
			this.position = position;
			this.color = color;
		}
	}

	[MenuItem("Tools/Parse Voxel Structure into Prefab")]
	public static void Do()
	{
		if (Selection.assetGUIDs.Length == 0 || Selection.assetGUIDs.Length > 1)
		{
			Debug.LogError("1 text file should be selected!");
			return;
		}

		var guid = Selection.assetGUIDs[0];
		var path = AssetDatabase.GUIDToAssetPath(guid);

		StreamReader file = new StreamReader(path);
		var rawVoxelDatas = ParseRawVoxelsFromFile(file);
		file.Close();

		var rootGameObject = CreateVoxelStructure(rawVoxelDatas);
		Selection.activeObject = rootGameObject;
		PrefabUtility.SaveAsPrefabAsset(rootGameObject, "Assets/Prefabs/VoxelStructures/" + Path.GetFileName(path) + ".prefab");
		DestroyImmediate(rootGameObject);
	}

	private static List<RawVoxelData> ParseRawVoxelsFromFile(StreamReader file)
	{
		var rawVoxelDatas = new List<RawVoxelData>();

		string line;
		while ((line = file.ReadLine()) != null)
		{
			if (line[0] == '#' || line[0] == ' ')
			{
				continue;
			}
			else
			{
				var split = line.Split();
				Vector3 position = new Vector3(float.Parse(split[0]), float.Parse(split[2]), float.Parse(split[1])); //goxel z = unity y
				rawVoxelDatas.Add(new RawVoxelData(position, split[3]));
			}
		}

		return rawVoxelDatas;
	}

	private static GameObject CreateVoxelStructure(List<RawVoxelData> rawVoxelData)
	{
		GameObject root = new GameObject();
		for (int i = 0; i < rawVoxelData.Count; i++)
		{
			var cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
			cube.layer = LayerMask.NameToLayer("Voxel");
			cube.transform.SetParent(root.transform);
			cube.transform.position = rawVoxelData[i].position;
			var material = GetOrCreateVoxelMaterial(rawVoxelData[i].color);
			cube.GetComponent<Renderer>().sharedMaterial = material;
		}
		return root;
	}

	private static Material GetOrCreateVoxelMaterial(string colorCode)
	{
		Material material = (Material)AssetDatabase.LoadAssetAtPath("Assets/Prefabs/VoxelStructures/Materials/" + colorCode + ".mat", typeof(Material));
		if (material == null)
		{
			material = CreateVoxelMaterial(colorCode);
		}
		return material;
	}

	private static Material CreateVoxelMaterial(string colorCode)
	{
		var material = new Material(Shader.Find("Standard"));
		Color color;
		ColorUtility.TryParseHtmlString("#" + colorCode, out color);
		if (color == null)
		{
			Debug.LogError("Couldn't parse color: #" + colorCode);
		}
		else
		{
			material.color = color;
		}
		AssetDatabase.CreateAsset(material, "Assets/Prefabs/VoxelStructures/Materials/" + colorCode + ".mat");
		return material;
	}
}
#endif