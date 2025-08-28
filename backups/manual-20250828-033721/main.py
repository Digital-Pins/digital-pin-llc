from fastapi import FastAPI
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from openai import OpenAI

# تحميل API Key
load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# إنشاء تطبيق FastAPI
app = FastAPI(title="Digital PIN AI Agent", version="1.0.0")

class MessageRequest(BaseModel):
    user: str
    message: str

# ---------- AI Manager ----------
class AIManager:
    def __init__(self, role_name):
        self.role_name = role_name

    def ask(self, message):
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": f"You are the {self.role_name} Agent at Digital PIN."},
                {"role": "user", "content": message}
            ]
        )
        return response.choices[0].message.content

# ---------- Define Agents ----------
class ERPAgent(AIManager):
    def __init__(self):
        super().__init__("ERP Project Manager")

    def summarize(self):
        return self.ask("Summarize the current ERP module status and challenges.")

class CMSAgent(AIManager):
    def __init__(self):
        super().__init__("CMS Content Strategist")

    def plan_updates(self):
        return self.ask("Generate a structured plan for content updates this month.")

class LearningAgent(AIManager):
    def __init__(self):
        super().__init__("E-Learning Specialist")

    def roadmap(self):
        return self.ask("Outline a roadmap for the e-learning platform under development.")

# ---------- Router ----------
def agent_router(agent_name, action="default"):
    agents = {
        "erp": ERPAgent(),
        "cms": CMSAgent(),
        "learning": LearningAgent()
    }

    agent = agents.get(agent_name.lower())
    if not agent:
        return "❌ Unknown agent."

    if agent_name.lower() == "erp":
        return agent.summarize()
    elif agent_name.lower() == "cms":
        return agent.plan_updates()
    elif agent_name.lower() == "learning":
        return agent.roadmap()
    else:
        return agent.ask("Handle general request.")

# ---------- FastAPI Routes ----------
@app.get("/")
async def root():
    return {"message": "🤖 Digital PIN AI Agent API", "status": "running"}

@app.post("/digitalpin/ai")
async def ai_endpoint(request: MessageRequest):
    try:
        # Extract agent type from message or use default
        agent_type = "general"
        if "erp" in request.message.lower():
            agent_type = "erp"
        elif "cms" in request.message.lower():
            agent_type = "cms"
        elif "learning" in request.message.lower() or "lms" in request.message.lower():
            agent_type = "learning"

        response = agent_router(agent_type, request.message)
        return {
            "user": request.user,
            "agent": agent_type,
            "response": response,
            "status": "success"
        }
    except Exception as e:
        return {
            "user": request.user,
            "error": str(e),
            "status": "error"
        }

# ---------- Test Run ----------
if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Digital PIN AI Agent Server...")
    uvicorn.run(app, host="127.0.0.1", port=8000)
