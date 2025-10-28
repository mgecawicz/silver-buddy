# SilverBuddy: Serverless Silver Price & Inventory Tracker

SilverBuddy is a serverless, cloud-native application designed to track real-time silver spot prices and manage a personal inventory of silver bullion.

This project serves as a comprehensive demonstration of a modern, event-driven architecture built on **AWS** using **Node.js**. The entire infrastructure is provisioned and managed as code using **Terraform**, showcasing a repeatable, automated deployment process.

---

## Key Features

* **Serverless API:** A secure, scalable, and cost-efficient HTTP API built with **AWS API Gateway** and **AWS Lambda**.
* **Infrastructure as Code (IaC):** The entire cloud infrastructure is defined declaratively and managed by **Terraform**, enabling automated, consistent, and repeatable deployments.
* **NoSQL Database:** Leverages **DynamoDB** for a highly available, single-digit millisecond performance database to store price history and user inventory.
* **Automated Deployment:** The Terraform configuration automatically packages the Node.js Lambda function, uploads it to **S3**, and deploys the new version.
* **Observability:** Integrated logging for both the API Gateway and the Lambda function is centralized in **CloudWatch**, providing robust monitoring and debugging capabilities.

---

## Architecture

This project follows a classic serverless API pattern, minimizing cost and operational overhead.

The request flow is as follows:

1.  A user sends an HTTPS request to the **API Gateway** endpoint.
2.  API Gateway routes the request to the appropriate **AWS Lambda** integration.
3.  The Lambda function (running **Node.js 20.x**) executes the core business logic. This includes fetching spot prices from an external API or performing CRUD (Create, Read, Update, Delete) operations on the user's inventory.
4.  All persistent data, such as inventory items or historical price data, is stored in a **DynamoDB** table.
5.  The Lambda function's deployment package is stored in an **S3 Bucket**. Terraform's `archive_file` data source handles zipping the code, and the `aws_s3_object` resource manages the upload.
6.  All API requests and Lambda execution logs are captured by **CloudWatch** for monitoring.

---

## Technology Stack

* **Application:** Node.js (v20.x)
* **Infrastructure as Code:** Terraform
* **Cloud Provider:** Amazon Web Services (AWS)
    * **Compute:** AWS Lambda
    * **API:** AWS API Gateway (HTTP)
    * **Database:** AWS DynamoDB
    * **Deployment Storage:** AWS S3
    * **Permissions:** AWS IAM
    * **Logging & Monitoring:** AWS CloudWatch

---

## Project Structure

The repository is structured to separate application code from infrastructure code, which is a common best practice.
```bash
├── api
│   └── test
│       └── hello.js
├── env.d.ts
├── environment
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.log
│   └── terraform.tf
├── eslint.config.ts
├── index.html
├── LICENSE
├── package-lock.json
├── package.json
├── public
│   └── favicon.ico
├── README.md
├── scripts
│   ├── destroy.sh
│   ├── setup.sh
│   ├── terraform.tfstate
│   └── update.sh
├── src
│   ├── __tests__
│   │   └── App.spec.ts
│   ├── App.vue
│   ├── main.ts
│   └── router
│       └── index.ts
├── tsconfig.app.json
├── tsconfig.json
├── tsconfig.node.json
├── tsconfig.vitest.json
├── vite.config.ts
└── vitest.config.ts
```
## Deployment

### Prerequisites

* An [AWS Account](https://aws.amazon.com/)
* [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
* [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
* [Node.js & npm](https://nodejs.org/en/) (v20.x+)

### Step-by-Step Deployment

1.  **Clone the Repository**
    ```sh
    git clone https://github.com/mgecawicz/silver-buddy
    cd silver-buddy
    ```

2.  **Install Application Dependencies**
    *(This is necessary for Terraform to package the `node_modules` folder).*
    ```sh
    npm install
    ```

3.  **Initialize Terraform**
    *(Navigate to the scripts directory and initialize the backend).*
    ```sh
    cd scripts
    chmod +x setup.sh
    ./setup.sh
    ```

4.  **Plan the Deployment**
    *(Review the changes Terraform will make to your AWS account).*
    ```sh
    terraform plan
    ```

5.  **Apply the Infrastructure**
    *(Build and deploy all AWS resources. Type `yes` when prompted).*
    ```sh
    terraform apply
    ```

After the deployment is complete, Terraform will provision all the resources defined in `main.tf`.

*(**Note:** To make this project complete, you would add an `outputs.tf` file to print the API Gateway URL. See the "Future Development" section).*

---

## Usage

The provided `main.tf` file deploys a sample `GET /hello` endpoint to validate that the architecture is working correctly.

* **Endpoint:** `GET /hello`
* **Description:** A simple test endpoint that invokes the `TestFunction` Lambda and returns its response.
* **Example Request:**
    ```sh
    # The URL will be available in your AWS API Gateway console
    curl https://<api-gateway-id>.execute-api.us-east-1.amazonaws.com/serverless_lambda_stage/hello
    ```

---

## Future Development

The current `main.tf` successfully deploys the foundational API architecture. The next steps involve evolving this backend into a full-stack, multi-tenant application.

* **Frontend Web Application & User Authentication (Phase 2)**
    * **Authentication:** Integrate **AWS Cognito** to manage the entire user lifecycle (sign-up, sign-in, password reset, and JWT-based session management).
    * **API Security:** Secure the API Gateway endpoints using a **Cognito User Pool Authorizer**. This ensures that all API routes (e.g., `POST /inventory`) are private and can only be accessed by authenticated users, who will pass a JWT in the `Authorization` header.
    * **Frontend Development:** Build a responsive single-page application (SPA) frontend using a modern framework (e.g., React, Vue, or Svelte) to provide a rich user interface for managing their silver inventory.
    * **Frontend Hosting:** Host the static frontend assets (HTML, CSS, JS) on **Amazon S3** and serve them globally via **Amazon CloudFront** for low-latency delivery and SSL.
    * **Data Isolation:** Update the DynamoDB data model to support multi-tenancy, using the user's Cognito-provided `sub` (a unique user ID) as a partition key to ensure a user can only ever access their own data.

* **Implement Full CRUD API (Phase 1 Backend)**
    * Expand the `hello.handler` into a robust API with full CRUD (Create, Read, Update, Delete) capabilities.
    * Create handlers for `POST /inventory`, `GET /inventory`, `PUT /inventory/{id}`, etc.
    * Add logic in the Node.js code to use the AWS SDK to interact with the `SilverHistory` (renamed to `UserInventory`) DynamoDB table.
    * Update `main.tf` to create the corresponding API Gateway routes and integrations for each new endpoint.

* **Scheduled Price Logging (Phase 1 Backend)**
    * Add an **AWS EventBridge (CloudWatch Events) Rule** to the Terraform configuration.
    * This rule will trigger a new Lambda function on a set schedule (e.g., every 15-30 minutes).
    * This function will call an external financial API (e.g., Metals-API) to fetch the real-time silver spot price and log it to a dedicated `PriceHistory` table in DynamoDB. The frontend application can then query this table to show historical price charts.
---

## Destroying the Infrastructure

To avoid ongoing AWS charges, you can destroy all the resources created by this project.

1.  Navigate to the `scripts` directory:
    ```sh
    cd scripts
    ```

2.  Run the destroy command:
    ```sh
    chmod +x destroy.sh
    ./destroy.sh
    ```