using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[ExecuteAlways] // �����ڱ༭��ģʽ��Ԥ��Ч��
public class Control : MonoBehaviour
{
    [Header("�������UI�������úõļ���UI�����ڴ�\\nȷ��UI����ײ�\\n���ض������ƹ淶��\\n��ʼ��LoadGameUiAnimationStart��\\n������LoadGameUiAnimationEnd��\\n���úú��ڰ�ť����PlayerGame()��LoadGame(��������)")]
    public GameObject loadGameUI;
    Animator loadGameAnimator;
    private void Awake()
    {
        try
        {
            loadGameAnimator = loadGameUI.GetComponent<Animator>();
        }
        catch
        {
            Debug.LogError("����Ӷ�����");
        }
        
    }
    private void Start()
    {
        StartCoroutine(LoadUI("LoadGameUiAnimationEnd"));

    }
    IEnumerator LoadGame(GameObject game)
    {
        Instantiate(game);
        yield return null;
    }
    public void PlayerGame()
    {
        StartCoroutine(LoadUI("LoadGameUiAnimationStart"));
    }
    IEnumerator LoadUI(string animationName)
    {
        try
        {
            loadGameAnimator.Play(animationName);
        }
        catch
        {
            Debug.LogError("����Ӷ�����,����ȷ��������������Ϊ��LoadGameUiAnimationStart ��������Ϊ��LoadGameUiAnimationStart");
        }


        yield return null;
    }
    public void LoadGame(int i)
    {
        StartCoroutine(IELoadGame(i));
    }
    IEnumerator IELoadGame(int i)
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(i);
        asyncLoad.allowSceneActivation = false; // ��ֹ�Զ������

        float time = 0;//�ж϶����Ƿ񲥷����
        AnimatorStateInfo stateInfo = loadGameAnimator.GetCurrentAnimatorStateInfo(0);
        float animationLength = stateInfo.length;
        while (!asyncLoad.isDone)
        {
            float progress = asyncLoad.progress;
            time += Time.deltaTime;
            if (progress >= 0.9f && time >= animationLength)
            {
                StartCoroutine(LoadUI("LoadGameUiAnimationEnd"));
                asyncLoad.allowSceneActivation = true; // �ֶ������
                Debug.Log("�л���������" + i);
            }
            yield return null;
        }
    }

}
