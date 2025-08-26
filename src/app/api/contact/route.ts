export async function GET() {
  return new Response(JSON.stringify({ ok: true, message: 'Contact API ready' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => ({}));
    // In production you'd validate and forward this to an email service or DB.
    return new Response(JSON.stringify({ ok: true, received: body }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
