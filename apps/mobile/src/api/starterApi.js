const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API starter");
  }
  return payload;
}

export async function listStarterCatalog(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/starter/catalog`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function createProgramFromStarter(jwt, starterKey, programName) {
  const res = await fetch(`${API_BASE_URL}/api/starter/create`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      starter_key: starterKey,
      program_name: programName
    })
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}
