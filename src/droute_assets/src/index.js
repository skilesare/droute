import { droute } from "../../declarations/droute";

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  // Interact with droute actor, calling the greet method
  const greeting = await droute.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
