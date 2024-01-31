from msal import ConfidentialClientApplication
import os
from langchain.chat_models import AzureChatOpenAI
from langchain.schema import HumanMessage
from langchain.embeddings import OpenAIEmbeddings
import openai 
import datetime

tid = "7c917db0-71f2-438e-9554-388ffcab8764"
auth = f"https://login.microsoftonline.com/{tid}"
os.environ['NO_PROXY']=".azure-api.net"
sample_prompt = "Please provide ML models supported by AWS"
tstamp = str(datetime.datetime.now()).replace(' ','').replace('-','').replace(':','').replace('.','')

def validate_endpoints(filename):
    of = open('output_'+tstamp+'.txt','w')
    temp_file = open(filename,'r')
    record_ls = temp_file.readlines()
    temp_file.close()
    for record in record_ls:
        of.write("--------------------------------------------------------------------\n")
        record = record.strip()
        rd_details = record.split(',')
        cid = rd_details[1]
        appid = rd_details[0]
        csecret = rd_details[2]
        api_base = rd_details[3]
        api_type = "azure_ad"
        api_version = "2023-05-15"
        deployment_name = rd_details[4]
        print("validation started for ", appid, deployment_name)
        of.write(appid+"\n")
        of.write(deployment_name+"\n")
        of.write(api_base)
        of.write("\n--------------------------------------------------------------------\n")        
        of.write("Token Generation for appid--------->>>>>>>>>  "+appid+"\n")
        atoken = access_token_generation(cid,csecret)
        of.write(atoken)
        of.write("\n--------------------------------------------------------------------\n") 
        try:       
            if 'gpt' in deployment_name:
                of.write("Sending Prompt>>>>"+sample_prompt+"\n")            
                response = chat_model_validation(atoken,api_version,api_type,api_base,deployment_name,sample_prompt)
                of.write("\nRecieved Response>>>>"+response)
                of2 = open('cost_funcs.py','w')
                of2.write(response)
                of2.close()       
                of.write("\n--------------------------------------------------------------------\n")     
            else:
                of.write("Sending Prompt>>>>"+sample_prompt)
                response = embedding_model_validation(atoken,api_version,api_type,api_base,deployment_name,sample_prompt)
                of.write("\nRecieved Response>>>>"+str(response)[:300]) 
            print("validation completed for ", appid, deployment_name)
        except:
            of.write("\nRecieved Response>>>>API Not Available/Other Error")  
            continue

    of.close()

def access_token_generation(cid,csecret):
    app = ConfidentialClientApplication(
        client_id=cid,
        client_credential=csecret,
        authority=auth
    )
    result = app.acquire_token_for_client(scopes=[cid+"/.default"])
    return result.get("access_token")
def chat_model_validation(api_key,api_version,api_type,api_base,deployment_name,prompt):
    try:
        llm2 = AzureChatOpenAI(
            openai_api_key=api_key,
            openai_api_type=api_type,
            openai_api_base=api_base,
            openai_api_version=api_version,
            deployment_name=deployment_name,
            verbose=True
        )
        result2 = llm2([HumanMessage(content=prompt)])
        return result2.content
    except openai.error.APIError as e:
        return e


def embedding_model_validation(api_key,api_version,api_type,api_base,deployment_name,prompt):
    try:
        embeddings = OpenAIEmbeddings(
            openai_api_key=api_key,
            openai_api_type=api_type,
            openai_api_base=api_base,
            openai_api_version=api_version,        
            deployment=deployment_name
        )
        result3 = embeddings.embed_documents(prompt)
        return result3
    except openai.error.APIError as e:
            return e    

validate_endpoints('input.csv')
