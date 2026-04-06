"""
Microservicio PlusZone: cálculo de afinidad candidato ↔ oferta por solapamiento de skills (índice de Jaccard).
El servidor Node puede exponerlo vía POST /api/match/score (proxy) cuando PYTHON_SERVICE_URL está definido.
"""

from __future__ import annotations

from typing import List

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(
    title="PlusZone — matching (Python)",
    version="1.0.0",
    description="Puntuación 0–100 según coincidencia de listas de habilidades tecnológicas.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class MatchScoreRequest(BaseModel):
    candidate_skills: List[str] = Field(default_factory=list, description="Skills del candidato")
    job_skills: List[str] = Field(default_factory=list, description="Skills requeridas u oferta")


def _normalize_skills(items: List[str]) -> set[str]:
    return {str(s).strip().lower() for s in items if s and str(s).strip()}


@app.get("/health")
def health():
    return {"status": "ok", "service": "pluszone-python-match"}


@app.post("/api/match/score")
def match_score(body: MatchScoreRequest):
    """
    Calcula un score 0–100 con el coeficiente de Jaccard entre dos conjuntos de etiquetas.
    Ampliación futura: pesos por skill, embeddings, etc.
    """
    a = _normalize_skills(body.candidate_skills)
    b = _normalize_skills(body.job_skills)
    if not a and not b:
        return {"score": 0.0, "matched": [], "method": "jaccard", "detail": "ambas listas vacías"}

    inter = a & b
    union = a | b
    jaccard = len(inter) / len(union) if union else 0.0
    score = round(jaccard * 100, 1)
    return {
        "score": score,
        "matched": sorted(inter),
        "method": "jaccard",
        "candidate_count": len(a),
        "job_count": len(b),
    }
