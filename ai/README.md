# From Whiteboard to Infrastructure

## The Vision

Picture a group of architects in a conference room. They're sketching infrastructure on a whiteboard — VNets, subnets, VMs, peering arrows, NSG rules. The ideas are flowing fast. Nobody stops to open Terraform. Nobody translates boxes into 500 lines of HCL. Nobody breaks the creative momentum to argue about resource block syntax.

Instead, someone takes a picture of the whiteboard. That image is handed to an AI agent. Minutes later, there's a TFVARS file — a compact, readable, reviewable declaration of everything on that whiteboard, ready to deploy.

**Sketch. Capture. Generate. Review. Deploy. Tear down. Repeat.**

That's the loop. Fifteen minutes or less from whiteboard to running infrastructure. Not because the AI is perfect — it won't be — but because the relational model makes AI output *reviewable*. An architect can hold the photo in one hand and the TFVARS in the other and verify it in minutes. When the AI guesses wrong on a value, there's a `# REVIEW:` comment marking exactly where. When the AI makes a structural decision, there's an `# EXPLAIN` comment showing its reasoning.

## Why This Works

### The relational model changes what AI has to do

Without AzRI, asking an AI to convert a diagram to Terraform means generating hundreds of lines of individual resource blocks — `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_network_interface`, `azurerm_network_security_group` — each with hardcoded cross-references. That's an engineering task. It's easy to get wrong and nearly impossible for a human to review against the original diagram.

With AzRI, the AI's job is reduced from **engineering** to **comprehension**. It doesn't generate resource blocks. It maps boxes and arrows to relational keys. The module handles the explosion from a handful of map entries into dozens of real Azure resources. That's a dramatically easier task for an AI to get right — and more importantly, easier for a human to catch when it's wrong.

### The abstraction mirrors how architects think

Architecture diagrams are relationships: "these VMs sit in this subnet," "this VNet peers to that one," "only SQL traffic enters here." AzRI's TFVARS express exactly that — nothing more. The output reads like the diagram. This is the same shift that SQL introduced for data: declare relationships, and the engine figures out the rest.

### Incomplete input is a feature, not a failure

Whiteboard sketches are never complete. They have no subscription IDs, no SKU sizes, no disk specs, no specific port numbers. In raw Terraform, every one of those gaps is a landmine. In AzRI, the relational model has sensible defaults, and the `# REVIEW:` / `# EXPLAIN` pattern turns gaps into a structured checklist. The diagram doesn't need to be complete — it just needs to capture *intent*.

### Two types of ambiguity, two different responses

Not all gaps are equal. Through testing, we found a critical distinction:

| Signal in the Diagram | Type | AI Response |
|----------------------|------|-------------|
| Missing CIDR, port, SKU, subscription ID | **Leaf value** | Best guess + `# REVIEW:` comment |
| "Mirror this," unclear topology, ambiguous boundaries | **Structural** | **Stop and ask the architect** |

Leaf-value gaps are easy to fix — edit one line. Structural gaps cascade through the entire file. Getting them wrong means regenerating, not editing. The AI must know the difference.

### The creative loop stays intact

Traditional IaC workflow is hostile to flow states: diagram → stop → translate → stop → debug → stop → fix references → stop → deploy. Every transition is a rupture. By the time you've translated the whiteboard to working Terraform, the insight that drove the diagram is gone.

This workflow eliminates the translation tax. The whiteboard *is* the input. The relational model *is* the interface. The AI handles the mechanical work. The architects stay in the room, stay in the zone, and review output that looks like what they just drew.

---

# How To: Diagram to TFVARS

Turn architecture diagrams — hand-drawn, Visio, draw.io, whatever — into AzRI TFVARS files using AI. This guide covers two methods: **Visual Studio Code** (local) and **GitHub.com** (web).

## The Process

1. You provide a diagram image (PNG, JPEG, photo of a whiteboard).
2. AI analyzes the diagram and maps it to AzRI's relational model.
3. AI generates a `.tfvars` file with:
   - `# EXPLAIN` comments showing how each diagram element was translated
   - `# REVIEW:` comments on values that were guessed and need human verification
4. You search for `# REVIEW:` in the output, fill in the blanks, and deploy.

### What AI handles well

- Counting VMs and mapping them to `virtual_machine_sets`
- Reading CIDR ranges off diagrams and mapping to `address_space`
- Interpreting arrows as peering, NSG rules, or routing
- Carving subnets from VNet address spaces when not specified
- Choosing sensible defaults for VM SKUs, OS images, and disk sizes

### What AI will ask you about

- **Structural ambiguity**: "Mirror deployment," "Hub network," "Replicate this" — anything that changes the shape of the output rather than a single value
- **Topology decisions**: Hub-spoke vs. mesh, single subscription vs. multi, same region vs. cross-region
- **Unclear boundaries**: When it's not obvious whether two boxes are separate subscriptions, resource groups, or just visual grouping

### What AI marks for your review

- Subscription IDs (always a placeholder GUID)
- CIDR ranges when not labeled on the diagram
- VM SKU sizes and disk configurations
- OS image selection (Windows vs. Linux)
- Port numbers when a protocol is named but not numbered (e.g., "SQL" → 1433 or 3306?)

## The Prompt

Use this prompt **exactly as written**. It contains all the instructions the AI needs. Paste it as your first message, then attach your diagram image in the follow-up.

---

### System Prompt (provide once at the start of the conversation)

````
Read and internalize the root README.md of this repository completely. This repo expresses
Terraform as a relational model so that architectural diagrams can be mapped directly to
TFVARS files.

Your role is to analyze architecture diagram images and convert them into TFVARS files
that can be plugged directly into infra_map.

Here is how you must approach this:

1. I will give you an image (PNG, JPEG, photo, etc.). It may be hand-drawn or produced
   by a tool like draw.io or Visio.

2. Analyze the image and convert it into a TFVARS file targeting infra_map.

3. The diagram will likely be incomplete. Handle gaps as follows:

   LEAF-VALUE GAPS (missing CIDRs, ports, SKUs, subscription IDs, etc.):
   - Fill in a best-guess value.
   - Add a "# REVIEW:" comment on the same line so the user can find and verify it.
   - Use "# REVIEW:" specifically when a single value needs to be reviewed.

   STRUCTURAL GAPS (unclear topology, ambiguous "mirror"/"hub"/"replicate" labels,
   uncertain subscription boundaries, unclear whether something is internal or external):
   - DO NOT GUESS. Ask me directly.
   - These decisions cascade through the entire TFVARS file and cannot be fixed by
     editing a single value.
   - Keep asking until you feel confident you can build the TFVARS file correctly.

4. Add "# EXPLAIN" comments throughout the TFVARS output:
   - Explain your thinking: how you went from a diagram element to a TFVARS structure.
   - Call out what was explicit in the diagram vs. what you inferred.
   - These comments help the reviewer understand and verify your translation.

5. Organize the TFVARS file with clear section headers (e.g., "# --- Networks ---")
   and group related tables together.

6. For resources required by AzRI but not shown in the diagram (e.g., key vaults for
   VM sets), create them with sensible defaults and explain why with "# EXPLAIN".
````

---

### Then, attach your diagram and say:

```
Here is my architecture diagram. Analyze it and generate a TFVARS file for infra_map.
```

That's it. The AI will either generate the TFVARS file or ask you structural questions first.

## Method A: Visual Studio Code (Copilot Chat)

### Prerequisites

- [Visual Studio Code](https://code.visualstudio.com/) installed
- [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) installed and signed in
- This repository cloned locally

### Steps

1. **Open the repository** in VS Code.

2. **Open Copilot Chat** — click the Copilot icon in the sidebar or press `Ctrl+Shift+I`.

3. **Select Agent Mode** — at the top of the chat panel, switch from "Ask" or "Edit" to **"Agent"** mode. This gives the AI access to your workspace files so it can read the README and model reference.

4. **Paste the system prompt** from above as your first message. Send it.

5. **Attach your diagram** — in your next message, click the paperclip icon (📎) in the chat input to attach an image file. Type:

   ```
   Here is my architecture diagram. Analyze it and generate a TFVARS file for infra_map.
   ```

6. **Answer any structural questions** the AI asks. These are about topology — not values.

7. **Review the generated TFVARS file.** The AI will create a `.tfvars` file in your workspace. Search for `# REVIEW:` to find every value that needs verification:
   - In VS Code: `Ctrl+Shift+F` → search `# REVIEW:`

8. **Iterate if needed.** You can paste updated diagrams or ask for changes in the same conversation. The AI maintains context.

### Tips for VS Code

- Use **Agent mode**, not Ask mode. The AI needs to read `README.md` and `variables.tf` to understand the model.
- If the AI doesn't read the README on its own, tell it: "Read the root README.md first."
- You can attach multiple images in one conversation for iterative refinement.
- Photos of whiteboards work — just make sure the text is legible.

## Method B: GitHub.com (Copilot in the Browser)

### Prerequisites

- A GitHub account with [GitHub Copilot](https://github.com/features/copilot) access
- This repository accessible on GitHub (public or in your org)

### Steps

1. **Navigate to the repository** on GitHub.com.

2. **Open GitHub Copilot Chat** — click the Copilot icon in the bottom-right corner of the GitHub interface, or press the Copilot chat button in the repository toolbar.

3. **Set the context** — make sure the chat knows which repository you're working with. If you opened Copilot from the repo page, it should already have context. If not, mention the repo:

   ```
   I'm working with the relational-infrastructure repository.
   ```

4. **Paste the system prompt** from above as your first message.

5. **Attach your diagram** — drag and drop an image or use the attachment button to include your architecture diagram. Then type:

   ```
   Here is my architecture diagram. Analyze it and generate a TFVARS file for infra_map.
   ```

6. **Answer any structural questions** the AI asks.

7. **Copy the generated TFVARS** from the chat output into a `.tfvars` file in your local clone of the repository.

8. **Search for `# REVIEW:`** to find all values that need human verification.

### Tips for GitHub.com

- The web Copilot may not automatically read all files in the repo. If the output doesn't match the AzRI model, explicitly ask: "Read the root README.md and infra_map/variables.tf first."
- For complex diagrams, the VS Code method is generally better because Agent mode can browse the full workspace.
- You can still iterate in the same conversation — paste a revised diagram or give corrections.

## Review Workflow

After generating a TFVARS file, follow this process:

### 1. Search for `# REVIEW:`

Every `# REVIEW:` comment marks a value the AI guessed. These are always leaf values — subscription IDs, CIDR ranges, SKUs, ports, region names.

```
# In VS Code
Ctrl+Shift+F → # REVIEW:

# In any editor
grep -n "# REVIEW:" your_file.tfvars
```

### 2. Read the `# EXPLAIN` comments

These tell you *why* the AI made each structural decision. They're your audit trail from diagram to code. If an `# EXPLAIN` comment doesn't match your intent, that section needs to be regenerated — tell the AI what's wrong.

### 3. Validate the topology

Check that:
- VNet peering directions match your intent (one-way vs. bidirectional)
- NSG rules have the correct source → destination flow
- VM sets are in the correct subnets
- Zone distribution (if any) matches the diagram's layout
- Resources that should be in different subscriptions/regions actually are

### 4. Deploy and iterate

```bash
terraform plan -var-file="your_file.tfvars"
```

Review the plan. If the topology is right but values are wrong, edit the TFVARS directly. If the topology is wrong, go back to the AI and explain what needs to change.

## Examples

For worked examples showing the full diagram-to-TFVARS translation with detailed commentary, see:

- [examples/01_peered_vnets](examples/01_peered_vnets/) — Two peered VNets, three VM roles, broad NSG rules
- [examples/02_distributed_app](examples/02_distributed_app/) — Availability zone distribution, port-specific NSGs, DR peering

Each example includes the original hand-drawn diagram, a step-by-step explanation of how the AI interpreted it, and the generated TFVARS output.
