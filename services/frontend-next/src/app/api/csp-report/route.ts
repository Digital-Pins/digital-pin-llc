// CSP Report collection endpoint (development / documentation phase)
// Accepts both older spec (application/csp-report, application/json with {"csp-report":{}})
// and newer Report API style (application/reports+json array of objects).
// For now we just log; optionally persist if LOG_CSP_REPORTS=1.

import { NextResponse } from 'next/server';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

// Generic loosely-typed CSP report structure (keys vary by browser)
// Use index signature to accommodate arbitrary fields.
interface CSPReport {
  [key: string]: unknown;
}
type ReportPayload = CSPReport | { 'csp-report'?: CSPReport; body?: CSPReport; type?: string } | Array<CSPReport>;

async function readBody(req: Request): Promise<ReportPayload | null> {
  const ct = req.headers.get('content-type') || '';
  // Limit size ~32KB
  const raw = await req.text();
  if (raw.length > 32 * 1024) return null;
  try {
    if (ct.includes('json') || ct.includes('csp-report') || ct.includes('application/reports')) {
      return JSON.parse(raw);
    }
  } catch (_e) {
    return null;
  }
  return null;
}

export async function POST(req: Request) {
  const payload = await readBody(req);
  if (!payload) {
    return new NextResponse(null, { status: 204 });
  }

  const reports: CSPReport[] = [];
  if (Array.isArray(payload)) {
    // Report API batch
    reports.push(...payload);
  } else if (payload['csp-report']) {
    reports.push(payload['csp-report'] as CSPReport);
  } else if (payload.body && payload.type === 'csp') {
    reports.push(payload.body as CSPReport);
  } else {
    reports.push(payload);
  }

  try {
    if (process.env.LOG_CSP_REPORTS === '1') {
      // Redact potentially sensitive URL query params
      const sanitized = reports.map(r => {
        const clone: CSPReport = { ...r };
        if (typeof clone['blocked-uri'] === 'string') {
          try {
            const u = new URL(clone['blocked-uri'] as string);
            u.search = '';
            clone['blocked-uri'] = u.toString();
          } catch {}
        }
        return clone;
      });
      console.warn('[CSP-REPORT]', JSON.stringify(sanitized).slice(0, 4000));
    }
  } catch {}

  // No body needed; browsers ignore content
  return new NextResponse(null, { status: 204 });
}

export function GET() {
  // Simple health check / manual test endpoint
  return NextResponse.json({ ok: true, purpose: 'csp-report-endpoint', mode: 'report-only' });
}
