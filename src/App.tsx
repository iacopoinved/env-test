import './App.css'

// Extend window with runtime env injected by entrypoint.sh
declare global {
  interface Window {
    __ENV__?: Record<string, string>
  }
}

// VITE_ vars baked in at build time by Vite
const buildTimeEnv: Record<string, string> = Object.fromEntries(
  Object.entries(import.meta.env)
    .filter(([k]) => k.startsWith('VITE_'))
    .map(([k, v]) => [k, String(v)])
)
// test

// Runtime vars injected by entrypoint.sh via /env-config.js -> window.__ENV__
const runtimeEnv: Record<string, string> = window.__ENV__ ?? {}

const th: React.CSSProperties = {
  textAlign: 'left',
  padding: '6px 12px',
  borderBottom: '2px solid #555',
  color: '#aaa',
}
const td: React.CSSProperties = {
  padding: '6px 12px',
  borderBottom: '1px solid #333',
  fontFamily: 'monospace',
  fontSize: 14,
}

function EnvTable({
  title,
  data,
  color,
}: {
  title: string
  data: Record<string, string>
  color: string
}) {
  const keys = Object.keys(data)
  return (
    <div style={{ marginBottom: 32 }}>
      <h2 style={{ color }}>{title}</h2>
      {keys.length === 0 ? (
        <p style={{ color: '#888' }}>— no variables found —</p>
      ) : (
        <table style={{ borderCollapse: 'collapse', width: '100%' }}>
          <thead>
            <tr>
              <th style={th}>Key</th>
              <th style={th}>Value</th>
            </tr>
          </thead>
          <tbody>
            {keys.map((k) => (
              <tr key={k}>
                <td style={td}>
                  <code>{k}</code>
                </td>
                <td style={td}>
                  {data[k] ? (
                    data[k]
                  ) : (
                    <span style={{ color: '#e57373' }}>EMPTY / MISSING</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  )
}

export default function App() {
  return (
    <div
      style={{
        maxWidth: 800,
        margin: '40px auto',
        padding: '0 20px',
        fontFamily: 'sans-serif',
      }}
    >
      <h1 style={{ marginBottom: 8 }}>🔍 Env Variable Debug</h1>
      <p style={{ color: '#888', marginBottom: 40 }}>
        <strong>Build-time vars</strong> are baked by Vite at build time (
        <code>import.meta.env.VITE_*</code>).
        <br />
        <strong>Runtime vars</strong> are injected by{' '}
        <code>entrypoint.sh</code> → <code>/env-config.js</code> →{' '}
        <code>window.__ENV__</code>.
      </p>

      <EnvTable
        title="✅ Build-time (import.meta.env.VITE_*)"
        data={buildTimeEnv}
        color="#81c784"
      />
      <EnvTable
        title="🚀 Runtime (window.__ENV__)"
        data={runtimeEnv}
        color="#64b5f6"
      />

      <hr style={{ borderColor: '#444', margin: '32px 0' }} />
      <h2 style={{ color: '#ffb74d' }}>ℹ️ Full import.meta.env</h2>
      <pre
        style={{
          background: '#1e1e1e',
          padding: 16,
          borderRadius: 8,
          overflow: 'auto',
          fontSize: 13,
        }}
      >
        {JSON.stringify(import.meta.env, null, 2)}
      </pre>
    </div>
  )
}
