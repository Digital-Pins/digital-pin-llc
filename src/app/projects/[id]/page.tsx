export const metadata = { title: 'Project — Digital PIN' };

export default function ProjectPage(props: unknown) {
  const { params } = props as { params: { id: string } };
  return (
    <main style={{padding: 24}}>
      <h1>Project {params?.id}</h1>
      <p style={{color: '#666'}}>Project details placeholder for id: {params?.id}</p>
    </main>
  );
}
