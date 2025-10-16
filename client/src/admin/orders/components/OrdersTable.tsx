import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { useOrders } from "../hooks/useOrders";
dayjs.extend(relativeTime);

interface OrdersTableProps {
  customerName: string;
  items: [
    {
      name: string;
      quantity: number;
      price: number;
    }
  ];
  totalAmount: number;
  status: string;
  createdAt: string;
}

export const OrdersTable = () => {
  const { data: orders, isLoading } = useOrders();

  if (isLoading) {
    return (
      <div className="text-[1.8rem] font-bold">
        Loading orders data please wait...{" "}
      </div>
    );
  }

  return (
    <div>
      <div className="overflow-x-auto">
        <table className="table">
          {/* head */}
          <thead>
            <tr>
              <th></th>
              <th>Customer</th>
              <th>Items</th>
              <th>Total Amount</th>
              <th>Status</th>
              <th>Created</th>
            </tr>
          </thead>

          <tbody>
            {orders?.map((order: OrdersTableProps, i: number) => {
              interface ItemProps {
                name: string;
                quantity: number;
                price: number;
              }
              return (
                <tr key={i}>
                  <th>{i + 1}</th>
                  <td>{order.customerName}</td>
                  <td className="flex flex-col items-center">
                    {order?.items.map((item: ItemProps, i: number) => {
                      return (
                        <div
                          className="rounded-md shadow-lg mb-2 w-[11rem] p-2 bg-white"
                          key={i}
                        >
                          <div>
                            <b>Name:</b> {item.name}
                          </div>
                          <div>
                            <b>Quantity:</b> {item.quantity}
                          </div>
                          <div>
                            <b>Price:</b> ₱ {item.price}
                          </div>
                        </div>
                      );
                    })}
                  </td>
                  <td> ₱ {order.totalAmount}</td>
                  <td
                    className={`${
                      order.status === "completed"
                        ? "text-green-600"
                        : order.status === "in-progress"
                        ? "text-yellow-600"
                        : order.status === "pending"
                        ? "text-red-600"
                        : "text-black"
                    }`}
                  >
                    {order.status}
                  </td>
                  <td>{dayjs(order.createdAt).fromNow()}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};
