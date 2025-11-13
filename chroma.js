import { ChromaClient } from "chromadb";
import { DefaultEmbeddingFunction } from "@chroma-core/default-embed";

async function testChromaConnection() {
  try {
    const embedder = new DefaultEmbeddingFunction();

    const client = new ChromaClient({
        host: "chroma.cloudpilot.com.br",
        // port: 443,
        ssl: true,
    });

    // Test connection by listing collections first
    console.log("Testing connection...");
    const collections = await client.listCollections();
    console.log("Connected successfully! Existing collections:");

    // Get or create collection
    let collection;
    const collectionName = "my_collection";

    try {
      collection = await client.getCollection({
        name: collectionName,
        embeddingFunction: embedder,
      });
      console.log("Using existing collection:", collectionName);
    } catch (error) {
      console.log("Creating new collection:", collectionName);
      collection = await client.createCollection({
        name: collectionName,
        embeddingFunction: embedder,
      });
    }

    await collection.add({
      ids: ["id1", "id2"],
      documents: [
        "This is a document about pineapple",
        "This is a document about oranges",
      ],
    });

    const results = await collection.query({
      queryTexts: ["This is a query document about hawaii"], // Chroma will embed this for you
      nResults: 2, // how many results to return
    });

    await collection.delete({
        ids: ["id1", "id2"],
    })

    console.log(results);
  } catch (error) {
    console.error("Failed to connect to ChromaDB:", error.message);

  }
}

testChromaConnection();